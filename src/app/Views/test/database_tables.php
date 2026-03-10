<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Database Tables</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            border-radius: 8px;
            padding: 30px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            max-width: 800px;
            margin: 0 auto;
        }
        h1 {
            color: #333;
            border-bottom: 2px solid #4CAF50;
            padding-bottom: 10px;
        }
        .info {
            background-color: #e8f5e9;
            padding: 15px;
            border-radius: 5px;
            margin-bottom: 20px;
        }
        .info p {
            margin: 5px 0;
            color: #2e7d32;
        }
        .tables-list {
            margin-top: 20px;
        }
        .table-item {
            background-color: #f9f9f9;
            padding: 12px;
            margin: 8px 0;
            border-left: 4px solid #4CAF50;
            border-radius: 3px;
            transition: transform 0.2s;
        }
        .table-item:hover {
            transform: translateX(5px);
            background-color: #f0f0f0;
        }
        .no-tables {
            color: #999;
            font-style: italic;
            padding: 20px;
            text-align: center;
            background-color: #fff3cd;
            border-radius: 5px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Database Tables List</h1>
        
        <div class="info">
            <p><strong>Database:</strong> <?= esc($database ?: 'Not configured') ?></p>
            <p><strong>Driver:</strong> <?= esc($driver) ?></p>
            <p><strong>Total Tables:</strong> <?= count($tables) ?></p>
        </div>
        
        <div class="tables-list">
            <h2>Tables:</h2>
            <?php if (empty($tables)): ?>
                <div class="no-tables">
                    No tables found in the database. Make sure your database connection is configured properly.
                </div>
            <?php else: ?>
                <?php foreach ($tables as $table): ?>
                    <div class="table-item">
                        <?= esc($table) ?>
                    </div>
                <?php endforeach; ?>
            <?php endif; ?>
        </div>
    </div>
</body>
</html>