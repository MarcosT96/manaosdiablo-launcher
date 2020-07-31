import QtQuick 2.12
import QtQuick.Layouts 1.3		// ColumnLayout
import QtQuick.Controls 2.1     // TextField
import QtQuick.Dialogs 1.3      // FileDialog

Item {
    property var game: {}
    property bool depApplied: false
    property bool depError: false
    property int activeHDIndex: 0
    property int activeMaphackIndex: 0
    property int boxHeight: 58

    function setGame(current) {
        // Set current game instance to the view.
        game = current

        // Textfield needs to be set explicitly since it's read only.
        if(game.location != undefined) {
            d2pathInput.text = game.location
        }

        // Update initial states without triggering an animation.
        overrideMaphackCfgSwitch.update()
        updateToggleBoxes(current)
        updateHDVersions(current)
        updateMaphackVersions(current)

    }

    function updateToggleBoxes(current) {
        if(current.flags != null) {
            windowModeFlag.active = current.flags.includes("-w")
            gfxFlag.active = current.flags.includes("-3dfx")
            skipFlag.active = current.flags.includes("-skiptobnet")
            nsFlag.active = current.flags.includes("-ns")
            nofixaspectFlag.active = current.flags.includes("-nofixaspect")
            directTxtFlag.active = current.flags.includes("-direct -txt")

        } else {
            windowModeFlag.active = false
            gfxFlag.active = false
            skipFlag.active = false
            nsFlag.active = false
            nofixaspectFlag.active = false
            directTxtFlag.active = false
        }
    }

    // updateHDVersions will set the correct index of the hd mod dropdown.
    function updateHDVersions(current) {
        if(settings.availableHDMods.length > 0) {
            // Find the correct index.
            for(var i = 0; i < settings.availableHDMods.length; i++) {
                if(settings.availableHDMods[i] == current.hd_version) {
                    activeHDIndex = i
                    hdVersion.currentIndex = i
                    return
                }
            }
        }

        // Default to first index in list.
        activeHDIndex = 0
        hdVersion.currentIndex = 0
    }

    // updateMaphackVersions will set the correct index of the maphack mod dropdown.
    function updateMaphackVersions(current) {
        if(settings.availableMaphackMods.length > 0) {
            // Find the correct index.
            for(var i = 0; i < settings.availableMaphackMods.length; i++) {
                if(settings.availableMaphackMods[i] == current.maphack_version) {
                    activeMaphackIndex = i
                    maphackVersion.currentIndex = i
                    return
                }
            }
        }

        // Default to first index in list.
        activeMaphackIndex = 0
        maphackVersion.currentIndex = 0
    }

    function makeFlagList() {
        var flags = []
        if(windowModeFlag.active) {
            flags.push("-w")
        }
        
        if(gfxFlag.active) {
            flags.push("-3dfx")
        }

        if(skipFlag.active) {
            flags.push("-skiptobnet")
        }

        if(nsFlag.active) {
            flags.push("-ns")
        }

        if(nofixaspectFlag.active) {
            flags.push("-nofixaspect")
        }

        if(directTxtFlag.active) {
            flags.push("-direct -txt")
        }

        return flags
    }

    function updateGameModel() {
        if(game != undefined) {
            var body = {
                id: game.id,
                location: d2pathInput.text,
                instances: gameInstances.currentIndex,
                override_bh_cfg: overrideMaphackCfgSwitch.checked,
                flags: makeFlagList(),
                hd_version: hdVersion.currentText,
                maphack_version: maphackVersion.currentText
            }
            
            settings.upsertGame(JSON.stringify(body))
        }
    }

    Item {
        id: currentGame
        width: parent.width
        height: 400

        anchors.horizontalCenter: parent.horizontalCenter

        ColumnLayout {
            id: settingsLayout
            width: (currentGame.width * 0.95)
            spacing: 2
            
            anchors.horizontalCenter: parent.horizontalCenter

            // D2 Directory box.
            Item {
                id: fileDialogBox
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: 85

                Column {
                    anchors.top: parent.top
                    topPadding: 10
                    spacing: 5

                    Title {
                        text: "SET DIABLO II DIRECTORY"
                        font.pixelSize: 13
                    }
                }

                Row {
                    anchors.bottom: parent.bottom
                    anchors.bottomMargin: 15

                    TextField {
                        id: d2pathInput
                        width: fileDialogBox.width * 0.80; height: 35
                        font.pixelSize: 11
                        color: "#676767"
                        readOnly: true
                        text: (game != undefined ? game.location : "")

                        background: Rectangle {
                            color: "#131313"
                        }
                    }

                    SButton {
                        id: chooseD2Path
                        label: "Open"
                        borderRadius: 0
                        borderColor: "#373737"
                        width: fileDialogBox.width * 0.20; height: 35
                        cursorShape: Qt.PointingHandCursor

                        onClicked: d2PathDialog.open()
                    }

                    // File dialog.
                    FileDialog {
                        id: d2PathDialog
                        selectFolder: true
                        folder: shortcuts.home
                        
                        onAccepted: {
                            var path = d2PathDialog.fileUrl.toString()
                            path = path.replace(/^(file:\/{2})/,"")
                            d2pathInput.text = path
                            
                            // Update the game model.
                            updateGameModel()
                        }
                    }
                }
                
                Separator{}
            }

             // Flags box.
            Item {
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: boxHeight

                Row {
                    topPadding: 10

                    Column {
                        id: parametersText
                        width: 225
                        
                        Title {
                            text: "LAUNCH PARAMETERS"
                            font.pixelSize: 13
                        }

                        SText {
                            text: "Set when the game launches"
                            font.pixelSize: 11
                            topPadding: 5
                            color: "#676767"
                        }
                    }

                    Column {
                        width: (settingsLayout.width - parametersText.width)

                         Row {
                            spacing: 2
                            leftPadding: 2

                            ToggleButton {
                                id: windowModeFlag
                                label: "-w"
                                width: 35
                                height: 35
                                onClicked: updateGameModel()
                            }

                            ToggleButton {
                                id: gfxFlag
                                label: "-3dfx"
                                width: 35
                                height: 35
                                onClicked: updateGameModel()
                            }

                            ToggleButton {
                                id: skipFlag
                                label: "-skip"
                                width: 35
                                height: 35
                                onClicked: updateGameModel()
                            }

                            ToggleButton {
                                id: nsFlag
                                label: "-ns"
                                width: 35
                                height: 35
                                onClicked: updateGameModel()
                            }

                            ToggleButton {
                                id: nofixaspectFlag
                                label: "-nofixaspect"
                                width: 70
                                height: 35
                                onClicked: updateGameModel()
                            }

                            ToggleButton {
                                id: directTxtFlag
                                label: "-direct -txt"
                                width: 70
                                height: 35
                                onClicked: updateGameModel()
                            }
                        }
                    }
                }
                
                Separator{}
            }


            // Game instances box.
            Item {
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: boxHeight

                Row {
                    topPadding: 10

                    Column {
                        width: (settingsLayout.width - instancesDropdown.width)
                        
                        Title {
                            text: "INSTANCES TO LAUNCH"
                            font.pixelSize: 13
                        }

                        SText {
                            text: "Number of this specific install that will launch when playing the game"
                            font.pixelSize: 11
                            topPadding: 5
                            color: "#676767"
                        }
                    }
                    Column {
                        id: instancesDropdown
                        width: 60
                        Dropdown{
                            id: gameInstances
                            currentIndex: ((game != undefined && game.instances != undefined) ? (game.instances) : 0)
                            model: [ 0, 1, 2, 3, 4 ]
                            height: 30
                            width: 60

                            onActivated: updateGameModel()
                        }
                    }
                }
                
                Separator{}
            }

            // Include maphack box.
            Item {
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: boxHeight

                Row {
                    topPadding: 10

                    Column {
                        width: (settingsLayout.width - includeMaphack.width)
                        Title {
                            text: "MAPHACK VERSION"
                            font.pixelSize: 13
                        }

                        SText {
                            text: "Select if you want any maphack installed"
                            font.pixelSize: 11
                            topPadding: 5
                            color: "#676767"
                        }
                    }
                    Column {
                        id: includeMaphack
                        width: 90

                        Dropdown{
                            id: maphackVersion
                            currentIndex: activeMaphackIndex
                            model: settings.availableMaphackMods
                            height: 30
                            width: 90

                            onActivated: updateGameModel()
                        }
                    } 
                }
                
                Separator{}
            }

            // Include HD box.
            Item {
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: boxHeight

                Row {
                    topPadding: 10

                    Column {
                        width: (settingsLayout.width - includeHD.width)
                        Title {
                            text: "HD MOD VERSION"
                            font.pixelSize: 13
                        }

                        SText {
                            text: "Select if you want any HD mod installed"
                            font.pixelSize: 11
                            topPadding: 5
                            color: "#676767"
                        }
                    }
                    Column {
                        id: includeHD
                        width: 90

                        Dropdown{
                            id: hdVersion
                            currentIndex: activeHDIndex
                            model: settings.availableHDMods
                            height: 30
                            width: 90

                            onActivated: updateGameModel()
                            
                        }
                    }
                }
                
                Separator{}
            }

            // Use default maphack config.
            Item {
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: boxHeight

                Row {
                    topPadding: 10

                    Column {
                        width: (settingsLayout.width - overrideMaphackCfg.width)
                        Title {
                            text: "OVERRIDE MAPHACK CONFIG"
                            font.pixelSize: 13
                        }

                        SText {
                            text: "Select if you want to provide your own custom BH.cfg"
                            font.pixelSize: 11
                            topPadding: 5
                            color: "#676767"
                        }
                    }
                    Column {
                        id: overrideMaphackCfg
                        width: 60
                        SSwitch{
                            id: overrideMaphackCfgSwitch
                            checked: ((game != undefined && game.override_bh_cfg != undefined) ? game.override_bh_cfg : false)
                            onToggled: updateGameModel()
                        }
                    } 
                }
                
                Separator{}
            }

             // Dep fix.
            Item {
                Layout.preferredWidth: settingsLayout.width
                Layout.preferredHeight: boxHeight

                Row {
                    topPadding: 10

                    Column {
                        width: (settingsLayout.width - depFixButton.width)
                        Title {
                            text: "DISABLE DEP"
                            font.pixelSize: 13
                        }

                        SText {
                            text: "Run if this install gets Access Violation (C0000005) error - requires reboot"
                            font.pixelSize: 11
                            topPadding: 5
                            color: "#676767"
                        }
                    }
                    Column {
                        id: depFixButton
                        width: 100
                        
                        PlainButton {
                            width: 100
                            height: 40
                            label: "Run"

                            onClicked: {
                                var success = diablo.applyDEP(d2pathInput.text)

                                if(success) {
                                    depApplied = true
                                    // Remove message after a timeout.
                                    depAppliedTimer.restart()
                                } else {
                                    depError = true
                                    // Remove message after a timeout.
                                    depErrorTimer.restart()
                                }
                            }
                        }
                    } 
                }

                // DEP success message.
                Rectangle {
                    visible: depApplied
                    width: parent.width
                    height: parent.height
                    color: "#00632e"
                    border.width: 1
                    border.color: "#000000"

                    SText {
                        text: "DEP fix successfully applied - don't forget to reboot!"
                        font.pixelSize: 11
                        anchors.centerIn: parent
                        color: "#ffffff"
                    }
                }

                // DEP error message.
                Rectangle {
                    visible: depError
                    width: parent.width
                    height: parent.height
                    color: "#8f3131"
                    border.width: 1
                    border.color: "#000000"

                    SText {
                        text: "There was an error while applying DEP, please try again!"
                        font.pixelSize: 11
                        anchors.centerIn: parent
                        color: "#ffffff"
                    }
                }
            }
        }
    }

    Timer {
        id: depAppliedTimer
        interval: 3000; running: false; repeat: false
        onTriggered: depApplied = false
    }

    Timer {
        id: depErrorTimer
        interval: 3000; running: false; repeat: false
        onTriggered: depError = false
    }
}
