# Distributed under MIT License
# Copyright (c) 2021 Remi BERTHOLET
from homekit import *

class Outlet(Accessory):
	""" Outlet homekit accessory """
	def __init__(self, **kwargs):
		""" Create outlet accessory. Parameters : name(string), on(bool), outletInUse(bool) and all Accessory parameters """
		Accessory.__init__(self, Accessory.CID_OUTLET, **kwargs)
		self.service = Service(name=kwargs.get("name","Outlet"), serviceUuid=Service.UUID_OUTLET)

		self.on = charactBoolCreate (Charact.UUID_ON, Charact.PERM_RWE, kwargs.get("on",False))
		self.service.addCharact(self.on)
		
		self.outletInUse = charactBoolCreate (Charact.UUID_OUTLET_IN_USE, Charact.PERM_RE, kwargs.get("outletInUse",False))
		self.service.addCharact(self.outletInUse)

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
	Homekit.play(Outlet(name="My Outlet"))

if __name__ == "__main__":
	main()