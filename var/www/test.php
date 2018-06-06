<?php
class Website {
	protected $task = '';

	public function __construct() {
		$this->task = isset($_GET['task']) ? $_GET['task'] : '';
	}

	public function run() {
		$this->navigation();

		$method = $this->task . 'Action';
		if (method_exists($this, $method)) {
			$this->$method();
		} else {
			$this->shortInfo();
		}
	}

	private function navigation() {
		$path = $_SERVER['SCRIPT_NAME'];
		?>
		<div class="navigation">
			<a href="<?php echo $path; ?>" class="btn btn-blue">Home</a>
			<a href="<?php echo $path; ?>?task=phpInfo" class="btn btn-green">PHP Info</a>
			<a href="<?php echo $path; ?>?task=testMysql" class="btn btn-orange">Test MySQL</a>
			<a href="<?php echo $path; ?>?task=testUpload" class="btn btn-red">Test Upload</a>
			<a href="<?php echo $path; ?>?task=testMail" class="btn btn-purple">Send E-Mail</a>

			<?php /*
			<a href="#" class="btn">Button</a>
			<a href="#" class="button-blue">Button</a>
			<a href="#" class="button-green">Button</a>
			*/ ?>
		</div>
		<?php
	}

	private function shortInfo() {
		?>
		<div class="container">
			<h2>Short info</h2>

			<table style="width: 100%;">
				<tr><th>Server</th><td><?php echo $_SERVER['SERVER_SOFTWARE']; ?></td></tr>
				<tr><th>PHP</th><td><?php echo phpversion(); ?></td></tr>
				<tr><th>Current Work Directory</th><td><?php echo getcwd(); ?></td></tr>
			</table>
		</div>
	<?php
	}

	private function getContentByTag($content, $tag) {
			if (preg_match_all('/<'.$tag.'[^>]*>(.*?)<\/'.$tag.'>/is', $content, $match)) {
					return $match;
			}
			return false;
	}

	private function phpInfoAction() {
		ob_start();
		phpinfo();
		$phpinfo = ob_get_clean();

		$body = $this->getContentByTag($phpinfo, 'body');
		if ($body !== false) {
			$body = $body[1][0];

			# Get style
			$style = $this->getContentByTag($phpinfo, 'style');
			if ($style !== false) {
				echo '<style>' . $style[1][0] . '</style>';
			}

			$body = preg_replace('/([a-zA-Z0-9]+),([a-zA-Z0-9]+)/s', '$1, $2', $body);

			$body = str_replace('%25', '%', $body);
			$body = str_replace('%25', '%', $body);
			$body = str_replace('%3A', ':', $body);
			$body = str_replace('%2C', ',', $body);
			$body = str_replace('%3D', '=', $body);
			$body = str_replace('%3F', '?', $body);
			$body = str_replace('%26', '&', $body);
			$body = str_replace('%7C', '|', $body);
			$body = str_replace('; ', ';<br>', $body);

			# Fix bugs
			$body = str_replace('module_Zend Optimizer', 'module_Zend_Optimizer', $body);

			# Colorize keywords values
			$body = preg_replace('/>(on|enabled|active)/i', '><span style="color:#090">$1</span>', $body);
			$body = preg_replace('/>(off|disabled)/i', '><span style="color:#f00">$1</span>', $body);

			echo $body;
		}
	}

	private function testMysqlAction() {
		?>
		<div class="container">
			<h2>MySQL test</h2>
			<p>
			<?php
			if (class_exists('mysqli')) {
				$mysqli = new \mysqli('127.0.0.1', 'root', 'root');
				if ($mysqli->connect_errno) {
					echo 'Failed to connect to MySQL: (' . $mysqli->connect_errno . ') ' . $mysqli->connect_error;
				}
				echo $mysqli->host_info;
			} else {
				echo 'MySQLi existiert nicht!';
			}
			?>
			</p>
		</div>
	<?php
	}

	private function testMailAction() {
		?>
		<div class="container">
			<h2>E-Mail test</h2>
			<?php
			echo 'SendMail Path: ' . ini_get('sendmail_path') . '<br/>';
			$result = mail('test@example.org', 'Test E-Mail PHP ' . phpversion(), 'This is a <b>development</b> on <b>PHP ' . phpversion() . '</b> test.');
			echo 'E-Mail ' . ($result ? '' : 'not ') . 'send.';
			?>
		</div>
		<?php
	}

	private function testUploadAction() {
		?>
		<div class="container">
			<h2>Upload test</h2>
			<?php
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
				if (in_array($_FILES['file']['type'], ['image/jpeg', 'image/png', 'image/gif'])) {
					$this->uploadShowImage($_FILES['file']['tmp_name'], $_FILES['file']['type']);
				}
			}
			?>
		</div>
		<?php
	}

	protected function uploadShowImage($filename, $type) {
		if (is_readable($filename)) {
			$handle = fopen($filename, 'rb');
			$content = '';
			while (!feof($handle)) {
					$content .= fread($handle, 1024);
			}
			fclose($handle);
			$base64 = base64_encode($content);
			echo '<img style="max-width: 100%; max-height: 500px;" src="data:' . $type . ';base64,' . $base64 . '">';
		}
	}
}

$website = new Website();
?><!DOCTYPE html>
<html><head>
	<meta charset="utf-8">
	<title>Test</title>

	<style>
	body {
		margin: 60px 0 0 0;
		color: #000000;
		background-color: #A0DDFE;
	}

	div.page {
		margin-top: 65px;
		margin-bottom: 50px;
	}

	/* Cyb */
	table {
		padding: 0px;
		border: 1px #0099CC solid;
		border-collapse: collapse;
		font-family: Verdana, Helvetica;
		font-size: 14px;
	}
	table th, td {
		padding: 2px 5px;
	}
	table th {
		border: 1px #0099CC solid;
		background-color: #82D0FF;
	}
	table tr:nth-child(odd) td {
		border: 1px #0099CC solid;
		background-color: #CCECFF;
	}
	table tr:nth-child(even) td {
		border: 1px #0099CC solid;
		background-color: #A0DDFE;
	}

	h1, h2, h3, h4, h5, h6 {
		font-family: Arial, sans-serif;
		color: #000000;
	}

	/* Navigation */
	.navigation {
		position: fixed;
		top: 0; left: 0;
		z-index: 1;
		width: 100%;

		margin: 0px 0px 5px 0px;
		padding: 2px 3px 2px 3px;
		border-bottom: 1px solid #0099CC;
		background-color: #82D0FF;
	}

	/* Container */
	.container {
		background-color: #FFFFFF;
		border: 2px solid #0099CC;
		font-family: Arial,Helvetica,sans-serif;
		font-size: 14px;
		margin: 30px auto 0px auto;
		padding: 20px;
		width: 900px;
	}

	.container h2 {
		border-bottom: 1px solid #A0DDFE;
		color: #0099CC;
		font-family: Tahoma,Verdana,Arial,Helvetica,sans-serif;
		font-size: 18px;
		font-weight: bold;
		margin-top: 0;
		text-transform: none;
	}

	/* Button Blue */
	.button-blue:link,
	.button-blue {
		display: inline-block;
		-moz-border-radius: .25em;
		border-radius: .25em;
		-webkit-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		-moz-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		background-color: #276195;
		background-image: -khtml-gradient(linear,left top,left bottom,from(#3c88cc),to(#276195));
		background-image: -moz-linear-gradient(#3c88cc,#276195);
		background-image: -ms-linear-gradient(#3c88cc,#276195);
		background-image: -webkit-gradient(linear,left top,left bottom,color-stop(0%,#3c88cc),color-stop(100%,#276195));
		background-image: -webkit-linear-gradient(#3c88cc,#276195);
		background-image: -o-linear-gradient(#3c88cc,#276195);
		filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#3c88cc',endColorstr='#276195',GradientType=0);
		-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr='#3c88cc', endColorstr='#276195', GradientType=0)";
		background-image: linear-gradient(#3c88cc,#276195);
		border: 0;
		cursor: pointer;
		color: #fff;
		text-decoration: none;
		text-align: center;
		font-size: 16px;
		padding: 0px 20px;
		height: 40px;
		line-height: 40px;
		min-width: 100px;
		text-shadow: 0 1px 0 rgba(0,0,0,0.35);
		font-family: Arial, Tahoma, sans-serif;
		-webkit-transition: all linear .2s;
		-moz-transition: all linear .2s;
		-o-transition: all linear .2s;
		-ms-transition: all linear .2s;
		transition: all linear .2s
	}
	.button-blue:hover, .button-blue:focus {
		-webkit-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.3), inset 0 12px 20px 2px #3089d8;
		-moz-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.3), inset 0 12px 20px 2px #3089d8;
		box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.3), inset 0 12px 20px 2px #3089d8;
	}
	.button-blue:active {
		-webkit-box-shadow: inset 0 2px 0 0 rgba(0,0,0,0.2), inset 0 12px 20px 6px rgba(0,0,0,0.2), inset 0 0 2px 2px rgba(0,0,0,0.3);
		-moz-box-shadow: inset 0 2px 0 0 rgba(0,0,0,0.2), inset 0 12px 20px 6px rgba(0,0,0,0.2), inset 0 0 2px 2px rgba(0,0,0,0.3);
		box-shadow: inset 0 2px 0 0 rgba(0,0,0,0.2), inset 0 12px 20px 6px rgba(0,0,0,0.2), inset 0 0 2px 2px rgba(0,0,0,0.3);
	}

	/* Button Green */
	.button-green:link,
	.button-green {
		display: inline-block;
		-moz-border-radius: .25em;
		border-radius: .25em;
		-webkit-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		-moz-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		background-color: #659324;
		background-image: -khtml-gradient(linear,left top,left bottom,from(#81bc2e),to(#659324));
		background-image: -moz-linear-gradient(#81bc2e,#659324);
		background-image: -ms-linear-gradient(#81bc2e,#659324);
		background-image: -webkit-gradient(linear,left top,left bottom,color-stop(0%,#81bc2e),color-stop(100%,#659324));
		background-image: -webkit-linear-gradient(#81bc2e,#659324);
		background-image: -o-linear-gradient(#81bc2e,#659324);
		filter: progid:DXImageTransform.Microsoft.gradient(startColorstr='#81bc2e',endColorstr='#659324',GradientType=0);
		-ms-filter: "progid:DXImageTransform.Microsoft.gradient(startColorstr='#81bc2e', endColorstr='#659324', GradientType=0)";
		background-image: linear-gradient(#81bc2e,#659324);
		border: 0;
		cursor: pointer;
		color: #fff;
		text-decoration: none;
		text-align: center;
		font-size: 16px;
		padding: 0px 20px;
		height: 40px;
		line-height: 40px;
		min-width: 100px;
		text-shadow: 0 1px 0 rgba(0,0,0,0.35);
		font-family: Arial, Tahoma, sans-serif;
		-webkit-transition: all linear .2s;
		-moz-transition: all linear .2s;
		-o-transition: all linear .2s;
		-ms-transition: all linear .2s;
		transition: all linear .2s;
	}
	.button-green:hover, .button-green:focus {
		-webkit-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.3), inset 0 12px 20px 2px #85ca26;
		-moz-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.3), inset 0 12px 20px 2px #85ca26;
		box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.3), inset 0 12px 20px 2px #85ca26;
	}
	.button-green:active {
		-webkit-box-shadow: inset 0 2px 0 0 rgba(0,0,0,0.2), inset 0 12px 20px 6px rgba(0,0,0,0.2), inset 0 0 2px 2px rgba(0,0,0,0.3);
		-moz-box-shadow: inset 0 2px 0 0 rgba(0,0,0,0.2), inset 0 12px 20px 6px rgba(0,0,0,0.2), inset 0 0 2px 2px rgba(0,0,0,0.3);
		box-shadow: inset 0 2px 0 0 rgba(0,0,0,0.2), inset 0 12px 20px 6px rgba(0,0,0,0.2), inset 0 0 2px 2px rgba(0,0,0,0.3);
	}

	.btn,
	.btn:link {
		display: inline-block;
		-moz-border-radius: .25em;
		border-radius: .25em;
		-webkit-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		-moz-box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		box-shadow: 0 2px 0 0 rgba(0,0,0,0.1), inset 0 -2px 0 0 rgba(0,0,0,0.2);
		border: 0;
		cursor: pointer;

		text-decoration: none;
		text-align: center;
		font-size: 16px;
		padding: 0px 20px;
		height: 40px;
		line-height: 40px;
		min-width: 100px;
		text-shadow: 0 1px 0 rgba(0,0,0,0.35);
		font-family: Arial, Tahoma, sans-serif;
		-webkit-transition: all linear .2s;
		-moz-transition: all linear .2s;
		-o-transition: all linear .2s;
		-ms-transition: all linear .2s;
		transition: all linear .2s;

		background-color: #eeeeee;
		color: #666666;
	}
	.btn:hover,
	.btn:focus {
		background-color: #fbfbfb;
	}

	.btn-blue,
	.btn-blue:link {
		background-color: #00a1cb;
		color: #ffffff;
	}
	.btn-blue:hover,
	.btn-blue:focus {
		background-color: #00b5e5;
	}

	.btn-green,
	.btn-green:link {
		background-color: #7db500;
		color: #ffffff;
	}
	.btn-green:hover,
	.btn-green:focus {
		background-color: #8fcf00;
	}

	.btn-orange,
	.btn-orange:link {
		background-color: #f18d05;
		color: #ffffff;
	}
	.btn-orange:hover,
	.btn-orange:focus {
		background-color: #fa9915;
	}

	.btn-red,
	.btn-red:link {
		background-color: #e54028;
		color: #ffffff;
	}
	.btn-red:hover,
	.btn-red:focus {
		background-color: #e8543f;
	}

	.btn-purple,
	.btn-purple:link {
		background-color: #87318c;
		color: #ffffff;
	}
	.btn-purple:hover,
	.btn-purple:focus {
		background-color: #99389f;
	}
	</style>
</head>
<body>
	<?php $website->run(); ?>
</body></html>
