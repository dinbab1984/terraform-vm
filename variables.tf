variable "image" {
	//default = "https://app.vagrantup.com/ubuntu/boxes/bionic64/versions/20230607.0.0/providers/virtualbox.box"
	default = "virtualbox.box"
}

variable "nodecount" {
	default = 1
}

variable "cpus" {
	default = 2
}

variable "memory" {
	default = "2048 mib"
}
