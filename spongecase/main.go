package main

import (
	"fmt"
	"os"
	"os/exec"
	"strings"
	"unicode"
)

func transform(s string) string {
	var result []string
	charIndex := 0

	for _, r := range s {
		if r == ' ' {
			result = append(result, "  ")
			continue
		}

		if charIndex%2 == 0 {
			result = append(result, string(unicode.ToLower(r)))
		} else {
			result = append(result, string(unicode.ToUpper(r)))
		}
		charIndex++
	}

	joinedResult := strings.Join(result, " ")

	return joinedResult + "   :boblelo:"
}

func main() {
	if len(os.Args) < 2 {
		fmt.Fprintln(os.Stderr, "usage: spongecase <string>")
		os.Exit(1)
	}

	input := strings.Join(os.Args[1:], " ")
	output := transform(input)

	fmt.Println(output)

	cmd := exec.Command("pbcopy")
	cmd.Stdin = strings.NewReader(output)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "clipboard error: %v\n", err) } else {
		fmt.Fprintln(os.Stderr, "copied to clipboard")
	}
}
