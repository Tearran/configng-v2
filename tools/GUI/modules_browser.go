package main

import (
	"log"
	"os"
	"path/filepath"
	"runtime"

	"github.com/webview/webview_go"
)

func main() {
	// Use the working directory for modules_browser.html path
	htmlPath, err := filepath.Abs("modules_browser.html")
	if err != nil {
		log.Fatalf("Cannot find modules_browser.html: %v", err)
	}

	if _, err := os.Stat(htmlPath); err != nil {
		log.Fatalf("modules_browser.html not found: %v", err)
	}

	url := "file://" + htmlPath
	if runtime.GOOS == "windows" {
		url = "file:///" + htmlPath // Windows needs three slashes
	}

	debug := true
	w := webview.New(debug)
	defer w.Destroy()
	w.SetTitle("configng-v2 Desktop Menu")
	w.SetSize(1024, 700, webview.HintNone)
	w.Navigate(url)
	w.Run()
}