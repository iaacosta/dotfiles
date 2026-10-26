package managers

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"runtime"
	"slices"
	"strings"

	"setup/internal/core"
)

func Detect() (core.Manager, error) {
	if runtime.GOOS == "darwin" {
		return Brew{}, nil
	}
	file, err := os.Open("/etc/os-release")
	if err != nil {
		return nil, err
	}
	defer file.Close()
	return forDistro(file)
}

func forDistro(osRelease io.Reader) (core.Manager, error) {
	var ids []string
	scanner := bufio.NewScanner(osRelease)
	for scanner.Scan() {
		key, value, _ := strings.Cut(scanner.Text(), "=")
		if key == "ID" || key == "ID_LIKE" {
			ids = append(ids, strings.Fields(strings.Trim(value, `"`))...)
		}
	}
	if err := scanner.Err(); err != nil {
		return nil, err
	}
	if slices.Contains(ids, "ubuntu") || slices.Contains(ids, "debian") {
		return Apt{}, nil
	}
	return nil, fmt.Errorf("unsupported Linux distro: %s", strings.Join(ids, ", "))
}
