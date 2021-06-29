<?php
require_once('db.php');


function getUntriggeredAlerts(){
	$conn= Db::conn();
		$stmt = $conn->prepare('SELECT user_alerts.device_device_id,user_alerts.device_user_id,user_alerts.triggered,user_alerts.trigger_timer, device.name, device.lastSeen FROM user_alerts JOIN device ON device.device_id = user_alerts.device_device_id WHERE user_alerts.triggered=0');
	$stmt -> execute();
		while($alert = $stmt ->fetch()){
		$alerts[]=$alert;
	}
	return $alerts;
}

function getPendingDownlinks(){
	$conn= Db::conn();
		$stmt = $conn->prepare('SELECT * from triggerQueue');
	$stmt -> execute();
		while($request = $stmt ->fetch()){
		$pending[]=$request;
	}
	return $pending;
}

function getUserMail($user_id){
	$conn= Db::conn();
	if(false === ($stmt = $conn->prepare('SELECT email FROM users where user_id=:user_id'))){
		echo 'error preparing statement: ' . $conn->error;
	}
	if(!$stmt -> bindParam(':user_id', $user_id)){
	echo('error binding user_id');
		return false;
	}
	$stmt -> execute();
	$res = $stmt ->fetch();
	return $res;
}
function getDevice($device){
	$conn= Db::conn();
	$stmt = $conn->prepare('SELECT * FROM device WHERE  device_id=:deviceID');
	$stmt -> bindParam(':deviceID', $device);
	$stmt -> execute();
	return ($stmt ->fetch());
}

function getSensorBySensorID($sensorID){
		$conn= Db::conn();
		$stmt = $conn->prepare('SELECT idSensor, device_id, SensorName, device_port, SensorType FROM sensors WHERE idSensor=:idSensor');
		$stmt -> bindParam(':idSensor', $sensorID);
		$stmt -> execute();
		$sensor = $stmt ->fetch();
	return $sensor;
}

function getTrigger($triggerID){
	$conn= Db::conn();
	if(false === ($stmt = $conn->prepare('SELECT * FROM disparadors where trigger_id=:trigger_id'))){
		echo 'error preparing statement: ' . $conn->error;
	}
	if(!$stmt -> bindParam(':trigger_id', $triggerID)){
	echo('error binding trigger_id');
		return false;
	}
	$stmt -> execute();
	$res = $stmt ->fetch();
	return $res;
}
function removeAlertFromQueue($queueID){
	$conn= Db::conn();
	if(false === ($stmt = $conn->prepare('DELETE from triggerQueue WHERE idtriggerQueue=:idtriggerQueue'))){
		echo 'error preparing statement: ' . $conn->error;
	}
	if(!$stmt -> bindParam(':idtriggerQueue',$queueID)){
		echo('error binding triggered');
		return false;
	}
	if (!$stmt->execute()) {
		print_r($stmt->errorInfo());
		return false;
	}
}
function setAlertTrigger($device_id,$user_id,bool $status){
	$conn= Db::conn();
	if(false === ($stmt = $conn->prepare('UPDATE user_alerts set triggered=:triggered WHERE device_user_id=:device_user_id AND device_device_id=:device_device_id'))){
		echo 'error preparing statement: ' . $conn->error;
	}
	//we cannot bind directly a ternary operation
	$triggered=$status==true?'1':'0';
	
	if(!$stmt -> bindParam(':triggered',$triggered)){
		echo('error binding triggered');
		return false;
	}
	if(!$stmt -> bindParam(':device_user_id', $user_id)){
		echo('error binding user_id');
		return false;
	}
	if(!$stmt -> bindParam(':device_device_id', $device_id)){
		echo('error binding device_id');
		return false;
	}
	if (!$stmt->execute()) {
		print_r($stmt->errorInfo());
		return false;
	}
}
?>
