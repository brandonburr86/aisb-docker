<?php

namespace App\Controllers;

use CodeIgniter\Controller;

class Test extends Controller
{
    public function index()
    {
        $db = \Config\Database::connect();
        
        $tables = [];
        
        if ($db->DBDriver === 'MySQLi') {
            $query = $db->query('SHOW TABLES');
            $result = $query->getResultArray();
            foreach ($result as $row) {
                $tables[] = array_values($row)[0];
            }
        } elseif ($db->DBDriver === 'Postgre') {
            $query = $db->query("SELECT tablename FROM pg_tables WHERE schemaname = 'public'");
            $result = $query->getResultArray();
            foreach ($result as $row) {
                $tables[] = $row['tablename'];
            }
        } elseif ($db->DBDriver === 'SQLite3') {
            $query = $db->query("SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'");
            $result = $query->getResultArray();
            foreach ($result as $row) {
                $tables[] = $row['name'];
            }
        } elseif ($db->DBDriver === 'SQLSRV') {
            $query = $db->query("SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE'");
            $result = $query->getResultArray();
            foreach ($result as $row) {
                $tables[] = $row['TABLE_NAME'];
            }
        }
        
        $data = [
            'tables' => $tables,
            'database' => $db->getDatabase(),
            'driver' => $db->DBDriver
        ];
        
        return view('test/database_tables', $data);
    }
}