<?php

use CodeIgniter\Router\RouteCollection;

/**
 * @var RouteCollection $routes
 */
$routes->get('/', 'Home::index');
$routes->post('api/signup', 'Auth::signup');
$routes->post('api/login', 'Auth::login');
$routes->post('api/payment', 'Payment::create');
$routes->get('api/get-users', 'UserApi::index');
