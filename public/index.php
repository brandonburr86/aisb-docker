<?php
/**
 * Quick stack-verification page.
 * Delete this file once you have installed CodeIgniter.
 */

echo "<h1>Docker Stack is Running</h1>";
echo "<h2>PHP Info</h2>";
echo "<p>PHP Version: " . phpversion() . "</p>";

// Check required extensions for CodeIgniter
$required = [
    'pdo', 'pdo_mysql', 'mysqli', 'mbstring', 'intl',
    'curl', 'xml', 'gd', 'zip', 'json', 'opcache'
];

echo "<h2>Required PHP Extensions</h2><ul>";
foreach ($required as $ext) {
    $loaded = extension_loaded($ext);
    $colour = $loaded ? 'green' : 'red';
    $status = $loaded ? 'OK' : 'MISSING';
    echo "<li style='color:{$colour}'>{$ext} — {$status}</li>";
}
echo "</ul>";

// Test MySQL connection
echo "<h2>MySQL Connection</h2>";
try {
    $dsn  = 'mysql:host=mysql;dbname=' . ($_ENV['MYSQL_DATABASE'] ?? 'codeigniter');
    $user = $_ENV['MYSQL_USER']     ?? 'ci4user';
    $pass = $_ENV['MYSQL_PASSWORD'] ?? 'ci4password';
    $pdo  = new PDO($dsn, $user, $pass);
    echo "<p style='color:green'>Connected to MySQL successfully!</p>";
    echo "<p>Server version: " . $pdo->getAttribute(PDO::ATTR_SERVER_VERSION) . "</p>";
} catch (PDOException $e) {
    echo "<p style='color:red'>MySQL connection failed: " . htmlspecialchars($e->getMessage()) . "</p>";
}
