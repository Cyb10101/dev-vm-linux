<?php
class Website {
	protected $task = '';

	public function __construct() {
		$this->task = isset($_GET['task']) ? $_GET['task'] : '';
	}

	public function run() {
		$this->menu();

		$method = $this->task . 'Action';
		if (method_exists($this, $method)) {
			$this->$method();
		} else {
			$this->phpInfoAction();
		}
	}

	private function menu() {
		$path = $_SERVER['SCRIPT_NAME'];
		?>
		<div style="margin: 5px auto; padding: 5px; border: 1px solid grey;">
			<a href="<?php echo $path; ?>">PHP Info</a> |
			<a href="<?php echo $path; ?>?task=testMysql">Test MySQL</a> |
			<a href="<?php echo $path; ?>?task=testUpload">Test Upload</a> |
			<a href="<?php echo $path; ?>?task=testMail">Send E-Mail</a>
		</div>
		<?php
	}

	private function shortInfo() {
		?>
		<div style="margin: 5px auto; padding: 5px; border: 1px solid grey;">
			<b>Server</b>: <?php echo $_SERVER['SERVER_SOFTWARE']; ?> |
			<b>PHP</b>: <?php echo phpversion(); ?>
		</div>
		<?php
	}

	private function phpInfoAction() {
		$this->shortInfo();
		phpinfo();
	}

	private function testMysqlAction() {
		if (class_exists('mysqli')) {
			$mysqli = new \mysqli('127.0.0.1', 'root', 'root');
			if ($mysqli->connect_errno) {
				echo 'Failed to connect to MySQL: (' . $mysqli->connect_errno . ') ' . $mysqli->connect_error;
			}
			echo $mysqli->host_info . '<hr />';
		} else {
			echo 'MySQLi existiert nicht!';
		}
	}

	private function testMailAction() {
		echo 'SendMail Path: ' . ini_get('sendmail_path') . '<br/>';
		$result = mail('test@example.org', 'Test E-Mail PHP ' . phpversion(), 'This is a <b>development</b> on <b>PHP ' . phpversion() . '</b> test.');
		echo 'E-Mail ' . ($result ? '' : 'not ') . 'send.';
	}

	private function testUploadAction() {
		$path = $_SERVER['SCRIPT_NAME'];
		?><form action="<?php echo $path; ?>?task=testUpload" method="post" enctype="multipart/form-data">
			<label for="file">File</label>
			<input type="file" name="file" id="file" required="required">
			<button type="submit">Upload</button>
		</form><?php
		if (isset($_FILES['file'])) {
			?><pre><code><?php
			print_r($_FILES['file']);
			?></code></pre><?php
		}
	}
}

$website = new Website();
$website->run();
