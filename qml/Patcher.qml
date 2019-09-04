import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4

Item {
    id: patcher
    height: 80
    anchors.left: parent.left
    anchors.leftMargin: 20
    anchors.verticalCenter: parent.verticalCenter

    Item {
        anchors.fill: parent
        visible: diablo.validatingVersion

        // Loading circle.			
        CircularProgress {
            size: 20
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            visible: diablo.validatingVersion
        }

        Title {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 35
            text: "Checking game versions..."
            font.pixelSize: 15
        }
    }

    // Show when we're patching and no error has occurred.
    Item {
        anchors.fill: parent 
        visible: (diablo.patching && !diablo.errored && !diablo.validatingVersion)

        ProgressBar {
            height: 8
            value: diablo.patchProgress
            width: parent.width
            anchors.verticalCenter: parent.verticalCenter
            
            style: ProgressBarStyle {
                background: Rectangle {
                    radius: 3
                    color: "#080805"
                    border.width: 1
                    border.color: "#171714"
                }
                
                progress: Rectangle {
                    radius: 3
                    color: "#e3530b"
                    border.width: 1
                    border.color: "#171714"
                }
            }
        }

        SText {
            anchors.bottom: parent.bottom;
            anchors.bottomMargin: 10
            text: diablo.status
            font.pixelSize: 12
        }
    }

    // Show when patcher errors.
    Item {
        anchors.fill:parent 
        visible: diablo.errored && !diablo.validatingVersion
        
        Image {
            id: patcherError
            fillMode: Image.PreserveAspectFit
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            width: 25
            height: 25
            source: "assets/svg/error.svg"
        }

        SText {
            id: patchError
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            text: "Couldn't patch game files"
            font.pixelSize: 15
            anchors.leftMargin: 30
            topPadding: 5
        }

        XButton {
            width: 120
            height: 40
            label: "TRY AGAIN"
            fontSize: 10
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: patchError.right
            anchors.leftMargin: 20

            onClicked: {
                diablo.applyPatches()
            }
        }
    }

    // Show when patching is done, no error occurred and the game version is valid.
    Item {
        anchors.fill:parent 
        visible: (!diablo.patching && !diablo.errored && !diablo.validatingVersion && diablo.validVersion)

        Title {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 30
            text: "Games are up to date"
            font.pixelSize: 15
        }

        Item {
            width: 350; height: parent.height
            anchors.verticalCenter: parent.verticalCenter
            anchors.right: parent.right;

            // Launch button.
            PlainButton {
                label: "PLAY"
                fontSize: 15
                clickable: diablo.validVersion
                width: 325; height: 50
                anchors.verticalCenter: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter

                onClicked: diablo.launchGame()
            }
        }
    }

    // Show when the Diablo version is invalid, we're not patching and there's no error.
    Item {
        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        width: 350
        height: 40
        visible: (!diablo.validVersion && !diablo.patching && !diablo.errored && !diablo.validatingVersion)

        Image {
            id: versionError
            fillMode: Image.PreserveAspectFit
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            width: 20
            height: 20
            source: "assets/svg/error.svg"
        }

        Title {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            anchors.leftMargin: 30
            text: "Games need to be updated"
            font.pixelSize: 15
        }

        XButton {
            width: 120
            height: 40
            label: "UPDATE NOW"
            fontSize: 10
            anchors.top: parent.top
            anchors.right: parent.right

            onClicked: {
                diablo.applyPatches()
            }
        }
    }

    Component.onCompleted: {
        if(settings.games.rowCount() > 0) {
            diablo.validateVersion()
        }
    }
}
