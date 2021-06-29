<?php
//Import PHPMailer classes into the global namespace
//These must be at the top of your script, not inside a function
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\SMTP;
use PHPMailer\PHPMailer\Exception;

//Load Composer's autoloader
require 'vendor/autoload.php';

//Create an instance; passing `true` enables exceptions

class MyMailer{

	public function SendMail($destination,$subject, $body){

		$mail = new PHPMailer(true);
		try {
			//Server settings
			$mail->SMTPOptions = array(
			'ssl' => array(
			'verify_peer' => false,
			'verify_peer_name' => false,
			'allow_self_signed' => true
			)
			);
			$mail->SMTPDebug = SMTP::DEBUG_SERVER;                      //Enable verbose debug output
			$mail->isSMTP();                                            //Send using SMTP
			$mail->Host       = '[PUT YOR SMTP SERVER HERE]';                     //Set the SMTP server to send through
			$mail->SMTPAuth   = true;                                   //Enable SMTP authentication
			$mail->Username   = '[SMTP USER NAME]';                     //SMTP username
			$mail->Password   = '[SMTP PASSWORD]';                               //SMTP password
			$mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;            //Enable implicit TLS encryption
			$mail->Port       = 587;                                    //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`

			//Recipients
			$mail->setFrom('[YOUR ORIGIN MAIL]', 'Mailer');
			$mail->addAddress($destination);     //Add a recipient Name is optional
			
			//Attachments
			//$mail->addAttachment('/var/tmp/file.tar.gz');         //Add attachments
			//$mail->addAttachment('/tmp/image.jpg', 'new.jpg');    //Optional name

			//Content
			$mail->isHTML(true);                                  //Set email format to HTML
			$mail->Subject = $subject;
			$mail->Body    = $body;
			//$mail->AltBody = 'This is the body in plain text for non-HTML mail clients';

			$mail->send();
			echo 'Message has been sent';
		} catch (Exception $e) {
			echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
		}
	}
}
?>