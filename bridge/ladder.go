package bridge

import (
	"fmt"
	"time"

	"github.com/nokka/slash-launcher/ladder"
	"github.com/therecipe/qt/core"
)

// LadderBridge is the connection between QML and the Go config.
type LadderBridge struct {
	core.QObject

	// Services.
	LadderService ladder.Service

	// Properties.
	_ bool `property:"loading"`
	_ bool `property:"error"`

	// Slots.
	_ func(mode string) `slot:"getLadder"`

	// Models.
	LadderModel *core.QAbstractListModel `property:"characters"`
}

// Connect will connect the QML signals to functions in Go.
func (b *LadderBridge) Connect() {
	b.ConnectGetLadder(b.getLadder)
	//b.ConnectSetData(b.setData)
}

func (b *LadderBridge) getLadder(mode string) {
	go func() {
		fmt.Println("SETTING LOADING")
		// Tell the GUI that we're fetching data.
		b.SetLoading(true)

		fmt.Println("SLEEPING 5 SEC")
		time.Sleep(5 * time.Second)

		// Set the ladder characters on the model.
		err := b.LadderService.SetLadderCharacters(mode)
		if err != nil {
			return
		}

		fmt.Println("SETTING LOADING TO FALSE")

		// Stop loading when we're done fetching ladder data.
		b.SetLoading(false)
	}()

	return
}