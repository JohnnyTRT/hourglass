pragma ComponentBehavior: Bound
import QtQuick
import org.kde.plasma.plasmoid

WallpaperItem {
	id: root

	//local items var for Wallpapers
	//local mode int for Modes
	property var items: []
	property int mode: 0

	//what wallpaper is currently displayed?
	property int currentIndex: 0

	//debug code ------------------
	//property int tickCount: 0
/*
	Text {
		anchors.top: parent.top
		anchors.left: parent.left
		text: "ticks: " + root.tickCount + "index: " + root.currentIndex + "time: " + root.minutesToTime(root.getTime()) + "length: " + root.items.length
		color: "white"
		font.pixelSize: 32  
		z:999
	}
	*/

	//actual desktop image
	Image {
		id: wallPaperImage
		anchors.fill: parent
		fillMode: Image.PreserveAspectCrop
		source: root.items.length > 0 ? root.items[root.currentIndex].path : "../images/hourglassDefault.png"
	}

	//when program starts
	Component.onCompleted: {
		root.loadConfig()
		root.currentIndex = root.findCurrent()
		root.updateWallpaper()
	}


	//loop, you can change interval to check for updates/update wallpaper quicker, i defaulted this to 60000 which is ~1 minute updates
	Timer {
		interval: 5000
		running: true
		repeat: true
		triggeredOnStart: true

		onTriggered: {
			//tick count is for debug info
			//root.tickCount++
			root.loadConfig()
			root.updateWallpaper()
		}
	}


	//load settings from configuration
	function loadConfig(){
		try {
			root.items = JSON.parse(root.configuration.Wallpapers || "[]")
		} catch (e) {
			root.items = []
		}

		root.mode = root.configuration.Mode ?? 0
	}

	//code to find what wallpaper should currently be displayed
	function findCurrent(){
		const currentTime = getTime()
		for(let i = 0; i < root.items.length; i++){
			if(currentTime < timeToMinutes(root.items[i].time)){
				return i > 0 ? i - 1 : root.items.length - 1
			}
		}
		return root.items.length - 1
	}

	//code to get current time
	function getTime(){
		const now = new Date()

		const hours = now.getHours()
		const minutes = now.getMinutes()

		return hours * 60 + minutes
	}

	//code to convert string time to minutes
	function timeToMinutes(time){
		const parts = time.split(":")
		return Number(parts[0]) * 60 + Number(parts[1])
	}

	//code to convert minutes back to string time
	function minutesToTime(minutes){
		minutes = minutes % 1440

		const hours = Math.floor(minutes / 60)
		const mins = minutes % 60 

		return String(hours).padStart(2,"0") + ":" + String(mins).padStart(2, "0")
	}

	//updateWallpaper function
	function updateWallpaper(){
		rigidUpdate()
	}

	//rigid update
	function rigidUpdate(){
		const newCurrentIndex = root.findCurrent()
		if(newCurrentIndex !== root.currentIndex) {
			root.currentIndex = newCurrentIndex
		}
	}

	//smooth update
	function smoothUpdate(){

	}

}
