package main

import (
	"bytes"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
	"testing"
)

func TestMain(t *testing.T) {
	build, _ := filepath.Abs("../build")
	filepath.Walk("../test", func(path string, info os.FileInfo, err error) error {
		if strings.HasSuffix(path, ".sh") {
			cmd := exec.Command("bash", filepath.Base(path))
			cmd.Dir = filepath.Dir(path)
			cmd.Env = append(os.Environ(), "PATH="+build+":"+"/bin")
			stderr := new(bytes.Buffer)
			cmd.Stderr = stderr
			output, err := cmd.Output()
			if err != nil {
				t.Errorf("FAIL: execution failed: " + path + ": " + err.Error() + " " + stderr.String())
			} else {
				outfile := strings.TrimSuffix(path, filepath.Ext(path)) + ".txt"
				expected, err := ioutil.ReadFile(outfile)
				if err != nil {
					t.Errorf("FAIL: error on reading output file: " + outfile)
				} else if strings.HasPrefix(string(output), strings.TrimSuffix(string(expected), "\n")) {
					t.Logf("PASS: " + path + "\n")
				} else {
					t.Errorf("FAIL: output differs: " + path + "\n")
				}
			}
		}
		return nil
	})
}
