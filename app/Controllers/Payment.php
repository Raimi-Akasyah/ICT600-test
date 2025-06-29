<?php
namespace App\Controllers;

use CodeIgniter\RESTful\ResourceController;
use App\Models\UserModel;

class Payment extends ResourceController
{
    public function create()
    {
        $user_id = $this->request->getVar('user_id');
        $card_number = preg_replace('/\D/', '', $this->request->getVar('card_number'));
        $expiry_date = $this->request->getVar('expiry_date') . "-01";
        $cvv = preg_replace('/\D/', '', $this->request->getVar('cvv'));
        $amount = floatval($this->request->getVar('amount'));

        $db = \Config\Database::connect();
        // Insert into credit_card table
        $db->table('credit_card')->insert([
            'user_ID' => $user_id,
            'card_number' => $card_number,
            'expiry_date' => $expiry_date,
            'cvv' => $cvv
        ]);

        // Fetch user's tier_ID
        $user = $db->table('users')->where('user_ID', $user_id)->get()->getRowArray();
        $tier_ID = $user ? $user['tier_ID'] : null;

        // Insert into payments table
        $reference = "TXN" . strtoupper(uniqid());
        $notes = "Paid via card";
        $db->table('payments')->insert([
            'user_ID' => $user_id,
            'tier_ID' => $tier_ID,
            'amount' => $amount,
            'status' => 'completed',
            'payment_date' => date('Y-m-d'),
            'reference' => $reference,
            'notes' => $notes
        ]);

        // Update user payment status
        $db->table('users')->where('user_ID', $user_id)->update([
            'payment_status' => 'paid',
            'membership_expiry' => date('Y-m-d', strtotime('+30 days')),
            'mem_countdown' => 30
        ]);

        return $this->respond(['success' => true, 'message' => 'Payment successful!']);
    }
}
