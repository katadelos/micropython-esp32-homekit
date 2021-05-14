# Distributed under MIT License
# Copyright (c) 2021 Remi BERTHOLET
from homekit import *

class Switch(Accessory):
	""" Switch homekit accessory """
	def __init__(self, **kwargs):
		""" Create switch accessory. Parameters : name(string), on(bool) and all Accessory parameters """
		Accessory.__init__(self, Accessory.CID_SWITCH, **kwargs)
		self.service = Service(name=kwargs.get("name","Switch"), serviceUuid=Service.UUID_SWITCH)
		
		self.on = charactBoolCreate (Charact.UUID_ON, Charact.PERM_RWE, kwargs.get("on",True))
		self.service.addCharact(self.on)
		self.on.setWriteCallback(self.writeOn)
		self.addService(self.service)

	def writeOn(self, value):
		if value:
			print("ON")
		else:
			print("OFF")
		self.on.setValue(value)

def main():
	# Initialize homekit engine
	Homekit.init()
	
	# Create accessory
	Homekit.play(Switch(name="My Switch"))

if __name__ == "__main__":
	main()