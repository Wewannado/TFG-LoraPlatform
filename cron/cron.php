<?php
require_once('mailer/mailer.php');
require_once('functions.php');
define('DEBUG', false);

function sendMail($deviceName,$deviceLastSeen,$mail){
	$myMailer= new MyMailer();
	$subject=("IOTPlatform: Device ".$deviceName." is down");
	$message=(' Hey user!<br> This is an automated alert send to you because we haven\'t heard about your device '.$deviceName. ' since '.$deviceLastSeen.'<br><br>The IOTPlatform team.');
	$myMailer->SendMail($mail,$subject,$message);
}
function checkAlerts(){
	//check if we need to send emails to our users
	$currentDate = new DateTime('NOW');
	$alerts=getUntriggeredAlerts();
	if($alerts){
		foreach ($alerts as $alert){
			//if the device is never seen (null) we dont check it.
			if($alert['lastSeen']){
				$d = new DateTime($alert['lastSeen']);
				$elapsed= ((int)(($currentDate->getTimestamp()-$d->getTimestamp())/60)) ;
				if(DEBUG){echo("checking device: ".$alert['name']." elapsed: ".$elapsed." alarm at: ".$alert['trigger_timer'].PHP_EOL);}
				//Check if the alert should be triggered
				if($alert['trigger_timer']<$elapsed){
					//Get user mail
					$res=getUserMail($alert['device_user_id']);
					//Send the mail
					sendMail($alert['name'],$alert['lastSeen'],$res['email']);
					//mark alert as Triggered.
					setAlertTrigger($alert['device_device_id'],$alert['device_user_id'],TRUE);
				}
			}
		}
	}
	else{
	if(DEBUG){echo("no alerts to check".PHP_EOL);}
	}
}


function createPayload($port,$sensorType,$data){
	$hexpayload.=str_pad(dechex($port), 2, "0", STR_PAD_LEFT);
	$hexpayload.=str_pad(dechex($sensorType), 2, "0", STR_PAD_LEFT);
	$hexdata=dechex($data);
	$hexpayload.=str_pad(dechex($data), 2, "0", STR_PAD_LEFT);
	$binary=hex2bin($hexpayload);
	$rawpayload=base64_encode($binary);
	return $rawpayload;
}



function sendCurl($dev_id,$port,$confirmed,$rawpayload){
$url = "https://integrations.thethingsnetwork.org/ttn-eu/api/v2/down/uabloratestrgc/aaaaa?key=ttn-account-v2.aJmGDE-uo5gE6qtxmI8i1hFGZ9tMJwqYHJ_JDPJe2IY";
$ch = curl_init( $url );
# Setup request to send json via POST.

$request = json_encode( array( "dev_id"=> $dev_id,"port"=> $port,"confirmed"=> $confirmed,"payload_raw"=> $rawpayload ) );
curl_setopt( $ch, CURLOPT_POSTFIELDS, $request );
curl_setopt( $ch, CURLOPT_HTTPHEADER, array('Content-Type:application/json'));
# Return response instead of printing.
curl_setopt( $ch, CURLOPT_RETURNTRANSFER, true );
# Send request.
$result = curl_exec($ch);
curl_close($ch);
}

function sendDownlinks(){
	$pending=getPendingDownlinks();
	if($pending){
		foreach ($pending as $alert){
			$trigger=getTrigger($alert['disparadors_trigger_id']);
			$sensor=getSensorBySensorID($trigger['output_sensor']);
			$device=getDevice($sensor['device_id']);
			//$dev_id="device_a";
			//our aplication data port on firmware devices is 2
			$port=2;
			$confirmed=false;
			$rawpayload=createPayload($sensor['device_port'],$sensor['SensorType'],$trigger['outputValue']);
			sendCurl($device['ttndev_id'],$port,$confirmed,$rawpayload);
			removeAlertFromQueue($alert['idtriggerQueue']);
		}
	}
}

checkAlerts();
sendDownlinks();



?>

