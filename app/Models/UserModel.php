<?php
namespace App\Models;

use CodeIgniter\Model;

class UserModel extends Model
{
    protected $table = 'users';
    protected $primaryKey = 'user_ID';
    protected $allowedFields = [
        'full_name', 'phone_num', 'address', 'DOB', 'email', 'password', 'mem_countdown', 'membership_expiry', 'tier_ID', 'payment_status'
    ];
    protected $returnType = 'array';
}
