<?php
namespace App\Filters;

use CodeIgniter\HTTP\RequestInterface;
use CodeIgniter\HTTP\ResponseInterface;
use CodeIgniter\Filters\FilterInterface;
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthFilter implements FilterInterface
{
    public function before(RequestInterface $request, $arguments = null)
    {
        $authHeader = $request->getHeaderLine('Authorization');
        if (!$authHeader || !preg_match('/Bearer\s(.*)/', $authHeader, $matches)) {
            return service('response')->setJSON(['error' => 'Token required'])->setStatusCode(401);
        }
        $token = $matches[1];
        $key = getenv('JWT_SECRET') ?: 'supersecretkey';
        try {
            $decoded = JWT::decode($token, new Key($key, 'HS256'));
            $request->user = $decoded;
        } catch (\Exception $e) {
            return service('response')->setJSON(['error' => 'Invalid token'])->setStatusCode(401);
        }
    }
    public function after(RequestInterface $request, ResponseInterface $response, $arguments = null) {}
}
