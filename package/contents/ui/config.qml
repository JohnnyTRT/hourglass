pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as Controls
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami


Kirigami.FormLayout {
	id: root

	required property var configDialog
	required property var wallpaperConfiguration

	property var items: []

	// mode control int 0 = rigid; 1 = smooth
	property int currentMode: 0

	Kirigami.PromptDialog {
		id: debugDialog
		title: "Hourglass Debug"
		subtitle: "tung tung tung sahur"
		standardButtons: Kirigami.Dialog.Ok
	}

	Component.onCompleted: {
		loadConfig()
	}

	function loadConfig(){
		try{
			root.items = JSON.parse(root.wallpaperConfiguration.Wallpapers || "[]")
		} catch (e) {
			root.items = []
		}

		//update model
		entryList.clear()
		for (let i = 0; i < root.items.length; i++){
			entryList.append({
				time: root.items[i].time,
				imagePath: root.items[i].path
			})
		}

		root.currentMode = root.wallpaperConfiguration.Mode
	}

	function saveConfig(){
		if(!root.wallpaperConfiguration){
			return
		}

		root.wallpaperConfiguration.Wallpapers = JSON.stringify(root.items)
		root.wallpaperConfiguration.Mode = root.currentMode

		root.configDialog.configurationChanged = true
	}

	Kirigami.Heading {
		text: "Wallpapers"
		level: 2
		Layout.fillWidth: true
	}

	Kirigami.AbstractCard {
		implicitWidth: 500
		implicitHeight: 300

		contentItem: ListView {
			model: entryList
			delegate: listDelegate
			clip:true
			spacing: 8
		}
	}


	ListModel{
		id: entryList
	}
	Component {
		id: listDelegate
		Controls.ItemDelegate{
			id: delegateRoot
			required property string time
			required property string imagePath
			required property int index

			width: ListView.view.width
			height: 72

			contentItem: RowLayout {
				spacing: 12

				Image {
					Layout.preferredWidth: 96
					Layout.preferredHeight: 54
					fillMode: Image.PreserveAspectCrop
					source: delegateRoot.imagePath
				}

				Controls.TextField {
					id: timeField

					text: delegateRoot.time
					placeholderText: "00:00"
					Layout.preferredWidth: 90

					function commitTime() {
						const validTime = root.getValidTime(delegateRoot.index, timeField.text)


						entryList.setProperty(delegateRoot.index, "time", validTime)
						root.items[delegateRoot.index].time = validTime
						timeField.text = validTime

						root.saveConfig()
					}

					onAccepted: {
						focus = false
						commitTime()
					}

				}
			}

		}
	}

	function timeToMinutes(time){
		const parts = time.split(":")
		return Number(parts[0]) * 60 + Number(parts[1])
	}

	function minutesToTime(minutes){
		minutes = minutes % 1440

		const hours = Math.floor(minutes / 60)
		const mins = minutes % 60 

		return String(hours).padStart(2,"0") + ":" + String(mins).padStart(2, "0")
	}


	function getValidTime(currentIndex, newTime) {
		// Must be exactly HH:MM
		const timeRegex = /^([0-1][0-9]|2[0-3]):([0-5][0-9])$/

		if (!timeRegex.test(newTime)) {
			return root.items[currentIndex].time
		}

		const newMinutes = timeToMinutes(newTime)

		if(currentIndex > 0){
			const prevMinutes = timeToMinutes(root.items[currentIndex - 1].time)

			if (newMinutes <= prevMinutes) {
				return root.items[currentIndex].time
			}
		}

		if(currentIndex < root.items.length - 1){
			const nextMinutes = timeToMinutes(root.items[currentIndex + 1].time)

			if(newMinutes >= nextMinutes){
				return root.items[currentIndex].time
			}
		}

		return newTime
	}

	FileDialog {
		id: fileDialog
		title: "Choose wallpaper image"

		nameFilters: ["Images (*.png *.jpg *.jpeg *.webp *.avif)"]

		onAccepted: {
			root.addWallpaper(selectedFile.toString())
		}
	}

	RowLayout {
		spacing: 8
		Controls.Button {
			text: "Add Wallpaper"
			onClicked: fileDialog.open()
		}

		Controls.Button {
			text: "Remove Last"
			enabled: root.items.length > 1 
			onClicked: root.removeLastWallpaper()
		}
		Controls.ComboBox {
			id: modeBox

			model: ["Rigid", "Smooth"]

			Component.onCompleted: {
				modeBox.currentIndex = root.currentMode
			}

			onActivated: {
				root.currentMode = modeBox.currentIndex
				root.saveConfig()
			}
		}
	}



	Kirigami.PromptDialog {
		id: invalidEntry
		title: "Hourglass Debug"
		subtitle: "Cannot insert item into list if last entry is 23:59 since later entries must have a later time"
		standardButtons: Kirigami.Dialog.Ok
	}

	function addWallpaper(imagePath){
		if(root.items[root.items.length - 1].time === "23:59"){
			invalidEntry.open()
			return
		}
		const previousTime = root.items[root.items.length -1].time

		let previousTimeMinutes = timeToMinutes(previousTime)
		let newTimeMinutes = previousTimeMinutes + 1 

		const newTime = minutesToTime(newTimeMinutes)

		const newEntry = {
			path: imagePath,
			time: newTime
		}

		let newItems = root.items.slice()
		newItems.push(newEntry)
		root.items = newItems

		entryList.append({
			imagePath: newEntry.path,
			time: newEntry.time 
		})

		saveConfig()

	}

	function removeLastWallpaper(){
		if (root.items.length <= 1) {
			return
		}

		let newItems = root.items.slice()
		newItems.pop()
		root.items = newItems

		entryList.remove(entryList.count - 1)

		saveConfig()
	}
	
}
