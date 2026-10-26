package managers

import (
	"strings"
	"testing"
)

func TestForDistro(t *testing.T) {
	cases := []struct {
		name      string
		osRelease string
		want      string
	}{
		{"ubuntu", "NAME=\"Ubuntu\"\nID=ubuntu\nID_LIKE=debian\n", "apt"},
		{"debian derivative", "ID=pop\nID_LIKE=\"ubuntu debian\"\n", "apt"},
		{"arch", "ID=arch\n", ""},
	}
	for _, tc := range cases {
		t.Run(tc.name, func(t *testing.T) {
			manager, err := forDistro(strings.NewReader(tc.osRelease))
			if tc.want == "" {
				if err == nil {
					t.Fatalf("want an unsupported error, got %v", manager.Name())
				}
				return
			}
			if err != nil || manager.Name() != tc.want {
				t.Fatalf("got %v, %v", manager, err)
			}
		})
	}
}
