<?php

namespace App\Console\Commands;

use Illuminate\Console\Command;
use Illuminate\Support\Facades\DB;
use PDO;

class DatabaseMonitor extends Command
{
    protected $signature = 'db:monitor';
    protected $description = 'Monitor database connection';

    public function handle()
    {
        try {
            $host = env('DB_HOST', 'db');
            $port = env('DB_PORT', '3306');
            $database = env('DB_DATABASE', 'crater');
            $username = env('DB_USERNAME', 'crater');
            $password = env('DB_PASSWORD', 'crater');

            $dsn = "mysql:host={$host};port={$port};dbname={$database}";
            $pdo = new PDO($dsn, $username, $password, [
                PDO::ATTR_TIMEOUT => 2,
                PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION
            ]);
            
            return 0;
        } catch (\Exception $e) {
            $this->error($e->getMessage());
            return 1;
        }
    }
} 