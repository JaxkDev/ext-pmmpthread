<?php

use pmmp\thread\Worker;
use pmmp\thread\Pool;
use pmmp\thread\Runnable;

/*
* Often an application will have singleton-like objects, such as PDO connections or such.
* 
* You cannot pass such objects into a Thread, because they are not thread-safe objects.
*
* Even if you could pass the object to a Thread, it would not be safe; They were never intended to be used that
* way and don't have the machinery that thread-safe objects have that make them safe to share.
*
* This may seem awkward, but the solution can be quite elegant, and is usually easy to achieve.
*
* This example shows the execution of some Collectables (the anon class) that require a connection to PDO.
*/
class PDOWorker extends Worker {

	/*
	* Note that we only pass in the configuration to create the connection
	*/
	public function __construct(array $config) {
		$this->config = serialize($config);
	}

	public function run() : void {
		self::$connection = 
			new PDO(...unserialize($this->config));
	}

	public function getConnection() { return self::$connection; }

	private $config;
	
	/*
	* static properties are thread-local - changes on one thread won't be seen by other threads
	*/
	private static $connection;
}

/*
* When the Pool starts new Worker threads, they will construct the
* PDO object before any Collectable objects are executed.
*/
$pool = new Pool(4, PDOWorker::class, [["sqlite:example.db"]]);

/*
* Now we can submit work to the Pool
*/

while (@$i++<10) {
	$pool->submit(new class extends Runnable {
		public function run() : void {
			var_dump($this->worker->getConnection());
		}
	});
}

$pool->shutdown();
?>
