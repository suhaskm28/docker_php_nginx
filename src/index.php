<?php
require __DIR__ . '/../vendor/autoload.php';

use Faker\Factory;

// generate some fake data
$faker = Factory::create();

echo "<h2>Fake Data Generation:</h2>";

for ($i = 0; $i < 5; $i++) {
    echo "Name: " . $faker->name . " Address: " . $faker->address . "<br>";
}

// confirmation message
echo "<p style='color:green; font-weight:bold;'>PHP and Nginx are working!</p>";

// also display phpinfo
echo "<h2>PHP Info:</h2>";
phpinfo();
