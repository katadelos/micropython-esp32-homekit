# Distributed under MIT License
# Copyright (c) 2021 Remi BERTHOLET
from homekit import *

class AirQualitySensor(Accessory):
	""" Air quality homekit accessory """
	def __init__(self, **kwargs):
		""" Create air quality accessory. Parameters : name(string), airQuality(int) and all Accessory parameters """
		Accessory.__init__(self, Accessory.CID_SENSOR, **kwargs)

		self.service = Service(name=kwargs.get("name","Air quality sensor"), serviceUuid=Service.UUID_AIR_QUALITY_SENSOR)

		self.airQuality = charactUint8Create (Charact.UUID_AIR_QUALITY, Charact.PERM_RE, kwargs.get("airQuality",0))
		self.airQuality.setConstraint(0, 5, 1)
		self.service.addCharact(self.airQuality)

		self.addService(self.service)
	
	def setAirQuality(self, value):
		""" Set the air quality """
		self.airQuality.setValue(value)

def main():
	# Initialize homekit engine
	Homekit.init()

	# Create air quality sensor
	sensor = AirQualitySensor(name="My air quality sensor", airQuality=0)
	
	# Create accessory
	Homekit.play(sensor)

	import time
	airQuality = 0

	# Manage the air quality (simple sample)
	while True:
		time.sleep(2)

		airQuality += 1
		if airQuality > 5:
			airQuality = 0

		# Change the accessory air quality 
		sensor.setAirQuality(airQuality)

if __name__ == "__main__":
	main()