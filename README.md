# Nim and ESP8266 Vagrant Development Box

This repository contains a Vagrant file and provisioning scripts to set up a Vagrant Box that can be used for Nim+ESP8266 development.

## Setup

Make sure the required dependencies are installed, [see below](#depencencies):

* Clone this repository
  - `git clone https://github.com/clj/nim-esp8266-vagrant.git`
* Change into the cloned repository
  - `cd nim-esp8266-vagrant`
* Start the Vagrant box
  - `vagrant up`
* This will take a while the first time while the parent box is downloaded and the ESP8266 toolchain is downloaded and compiled.
* SSH into the box
  - `vagrant ssh`

## Compiling the Bundled Examples

Examples from the https://github.com/clj/nim-esp8266-examples are available in the Vagrant box. These examples can be compiled and uploaded to an ESP8266 board:

* Plug your ESP8266 board or programmer into a USB port
* Run `./attach-esp` to attach the board or programmer to the Vagrant Box

Inside the Vagrant Box (`vagrant ssh`):

* Change to the examples directory
  - `cd ~/src/nim-esp8266-examples`
* Change to an example of your choice
  - E.g. `cd blinky`
* Compile and flash the attached ESP8266
  - `make flash`

## Compiling Your Own Programs

The `synced` directory in the repository is synced to the running Vagrant Box. Put your projects in that directory and you can compile them from within the vagrant box (while still running the editor on your host computer):

* `vagrant ssh`
* `cd synced`
* e.g.: `cd my_project`
* `make`

## Dependencies

* [VirtualBox](https://www.virtualbox.org)
* [Vagrant](https://www.vagrantup.com)

### Installing the Dependencies on OS X using Homebrew:

  [Install Homebrew](https://brew.sh) if you have not already done so.

  - `brew cask install virtualbox`
  - `brew cask install vagrant`
