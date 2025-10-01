package config

import (
	"log"
	"os"

	"github.com/spf13/viper"
)

// Config contains global application information
type Config struct {
	Version       string
	Name          string
	Commit        string
	Date          string
	WD            string
	UpdateWorkers int
	SearchWorkers int
	PluginLimit   int
	ThemeLimit    int
	Host          string
	Domains       string
	Standalone    bool
	DevMode       bool
	Ports         struct {
		HTTP  string
		HTTPS string
	}
}

// Setup creates, fills and returns the Config struct
func Setup(version, commit, date string, dev bool) *Config {
	viper.SetDefault("name", "wpdirectory")
	viper.SetDefault("commit", "")
	viper.SetDefault("date", "")
	viper.SetDefault("updateworkers", 4)
	viper.SetDefault("searchworkers", 6)
	viper.SetDefault("pluginlimit", 5000)
	viper.SetDefault("themelimit", 1000)
	viper.SetDefault("host", "http://localhost")
	viper.SetDefault("domains", "wpdirectory.net,www.wpdirectory.net")
	viper.SetDefault("standalone", false)
	viper.SetDefault("dev", false)
	viper.SetDefault("ports.http", "80")
	viper.SetDefault("ports.https", "443")

	viper.AddConfigPath("/etc/wpdir/")
	viper.AddConfigPath(".")

	viper.SetConfigType("yaml")

	err := viper.ReadInConfig()
	if err != nil {
		log.Printf("Error reading config file: %s\n", err)
	}

	wd, err := os.Getwd()
	if err != nil {
		log.Fatalf("Error getting Working Directory: %s\n", err)
	}

	config := &Config{
		Version:       version,
		Name:          viper.GetString("name"),
		Commit:        commit,
		Date:          date,
		WD:            wd,
		UpdateWorkers: viper.GetInt("updateworkers"),
		SearchWorkers: viper.GetInt("searchworkers"),
		PluginLimit:   viper.GetInt("pluginlimit"),
		ThemeLimit:    viper.GetInt("themelimit"),
		Host:          viper.GetString("host"),
		Domains:       viper.GetString("domains"),
		Standalone:    viper.GetBool("standalone"),
		DevMode:       viper.GetBool("dev"),
	}

	config.Ports.HTTP = viper.GetString("ports.http")
	config.Ports.HTTPS = viper.GetString("ports.https")

	return config
}
