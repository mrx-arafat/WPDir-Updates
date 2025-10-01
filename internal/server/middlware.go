package server

import (
	"net/http"

	"github.com/prometheus/client_golang/prometheus"
	"github.com/prometheus/client_golang/prometheus/promhttp"
)

func metricsMiddleware(h http.Handler) http.Handler {
	return promhttp.InstrumentHandlerCounter(
		prometheus.NewCounterVec(
			prometheus.CounterOpts{
				Name: "http_requests_total",
				Help: "Total number of HTTP requests",
			},
			[]string{"code", "method"},
		),
		h,
	)
}
