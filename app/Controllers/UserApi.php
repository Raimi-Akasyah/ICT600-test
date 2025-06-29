<?php
namespace App\Controllers;

use App\Models\UserModel;
use CodeIgniter\RESTful\ResourceController;

class UserApi extends ResourceController
{
    public function index()
    {
        $userModel = new UserModel();
        $db = \Config\Database::connect();
        $users = $db->table('users u')
            ->select('u.user_ID, u.full_name, u.email, u.tier_ID, u.payment_status, u.membership_expiry, t.tier_name')
            ->join('tier t', 'u.tier_ID = t.tier_ID', 'left')
            ->get()->getResultArray();
        $result = [];
        foreach ($users as $row) {
            // Calculate countdown
            $today = date_create(date('Y-m-d'));
            $expiry = date_create($row['membership_expiry']);
            $interval = $expiry && $row['membership_expiry'] ? date_diff($today, $expiry) : false;
            $countdown = ($interval && !$interval->invert) ? $interval->days . ' days' : '0 days';
            $result[] = [
                'id' => $row['user_ID'],
                'name' => $row['full_name'],
                'email' => $row['email'],
                'tier' => $row['tier_name'],
                'tier_ID' => $row['tier_ID'],
                'payment' => $row['payment_status'],
                'expiry' => $row['membership_expiry'],
                'countdown' => $countdown
            ];
        }
        return $this->respond($result);
    }
}
