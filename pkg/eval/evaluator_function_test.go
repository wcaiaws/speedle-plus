//Copyright (c) 2018, Oracle and/or its affiliates. All rights reserved.
//Licensed under the Universal Permissive License (UPL) Version 1.0 as shown at http://oss.oracle.com/licenses/upl.

package eval

import (
	"crypto/tls"
	"crypto/x509"
	"encoding/json"
	"fmt"
	"net/http"
	"testing"

	adsapi "github.com/teramoby/speedle-plus/api/ads"
	"github.com/teramoby/speedle-plus/api/ext"
)

var (
	funcServerCert = `-----BEGIN CERTIFICATE-----\nMIIFJTCCAw2gAwIBAgIUbBFOch4Bca7VLOWkf7jhMwNwsdMwDQYJKoZIhvcNAQEL\nBQAwFDESMBAGA1UEAwwJbG9jYWxob3N0MB4XDTI2MDExMTEwMzk0M1oXDTM2MDEw\nOTEwMzk0M1owFDESMBAGA1UEAwwJbG9jYWxob3N0MIICIjANBgkqhkiG9w0BAQEF\nAAOCAg8AMIICCgKCAgEA8dc7Z8f6U5fzu+pvLsrX8R0DW433nL80l6ydiA4u3iQ1\nZe6XfwBa32YaO2v3UEV6jLlgQTZrDuG9bYCGHfKCAvCV8ISNF919Xxe6luu32Fo/\nK455cn1CMzN161yucVHG3Z54ejnPI3l8KzUhcs1Gn49IS48Gyihl0TVLYpx1Sn9R\nAMRcRYqtGO/Noqf2YE/OsfJjvQa3zac4UNYKKiPgW67Qhru6y5WDdhp7UcPvPU1f\npIVlaltaL6wneUg2fBKAF9fb82Ka4pQBgV1ZsFoiZDYoZ/QsWvw2XUeG8+idRhIp\nUX5i3n9gcaJRkBl+ZhvmDFwzUyu9cMp2a+8ZHFZDL1tCtLAzHYVH0rM1gW79K0W7\nyMy/1LjPaPLUFJx/SpP4xCKULC9tmwL2omlSALE4LC9T8jp3b3vy4WkPo4yb01UW\nKg5pYP9053ZDcHjEDjASrTw2pTt4afkyQVolfytQmPWGXZGWjT56NOgg77NLfq2f\noWfGmNez+kszll5NLm4xDNauqK+stzH4cyQXTqdUS8xr2WkKN4b7Dk1gHf8dgw82\n0rRLuX6QhXFd1tmzn5JDHG04tzHJuXO6dTH5ej3dTux8FrzBblJ2EcxivYzRvtcS\na2H9JInc4rtIIUrO45Ioqn5VTKWayC4dHaIv7c1D0xXavg2fzP3cO0Cxx9Nul8cC\nAwEAAaNvMG0wHQYDVR0OBBYEFBbz9v1l5ttmy9ii5OUMDtwT2g04MB8GA1UdIwQY\nMBaAFBbz9v1l5ttmy9ii5OUMDtwT2g04MA8GA1UdEwEB/wQFMAMBAf8wGgYDVR0R\nBBMwEYIJbG9jYWxob3N0hwR/AAABMA0GCSqGSIb3DQEBCwUAA4ICAQCziZYFqEAN\nMCb6l8Y4nR8lb1Uv3FHXEfZbuzStnaJzLxHcSqTUB/bFy/TCENfJ9IaSlQzG2YUQ\nrp4I6Vc+kWEJnkMSQtSRbu+cGyNHJUQ9xJ1o57V/GvpOm3dJaKgFbLMnNsBV8Q5r\nJYCkhfS34AQm+yTSl2yBkRiQIWfNJT+KzQppQRNo3vis0JD+OIFQf0b8urpb09LK\nQUKF92qWb3acLBuvhFjOtziFRgVQiDZMRwfNIMJg+4I8tpniQXeu210LNqfu2d3o\nSAqbV1+8nSYcXLpd7fJOhQxSAgispw6cSund2GLIjmFM6Udi41VUV4MvgT3ik4e+\nnl6fTjvf3I1tDQzqMWyWjL9MVuoPgHWI6m2Ujwt8CQUgZZeI+WdvFqO2SnIJ5cDP\nZ7mDBHTPMxMQ+7sPbWJ8oUnvK8fU5GeyVaMSN81RGsog9EMnz5uCy54+gXRYedXZ\nk6BrfL2a7Zucfut4TlziBjDWgAZ+PF1qPSa/t/nB2foKHndZaXjw62xJ+OmTIlqo\n6peh+fQcy5HEXGxTxLlxWjaLwc9pbPzTuy304eB+wqOs4myUBPWiLkBao+tRyoIp\nJpc4PgtSlxj1bB4JhIV8ok17BMg3II3oGCnMct+/H2AlLN/yBtwiDF/0BMNM15Mt\nYFXmnh5emuGaBsA2gTJU4LLCjzfoHwH3cA==\n-----END CERTIFICATE-----\n`
	funcServerKey = `-----BEGIN PRIVATE KEY-----\n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\nRVrDWMI6LMMywuxwAEmsuXsQOw2YUvofKoBXyAkCggEACInHpcbVevRli+z2ZHH5\nPaaM8ZUpYQonzJ2tY8/OWNk7mrj1L7oLD+HOO2fXFJSJLqFQlw5ElqGxnkK9ocOf\ni+uobpHB5mVruUoQxMzRAmtx3Y0xIaZJqt2N/8Q01nrjYv8cmd10gtTW+YhoXIl9\ujU8VlHhF/vmDmsD10T4F8V9yUU6NwsOwSnL5T6l0MpPJvpCtGEXlzxtvmumeBLH\ny+HHWeJNiCiPFGarVBt+XxZMzDRd62c6Ef160l2DUL4xse3tG12+vS4KW8UWiAr6\nA2B2GhD1Wuqzu3ilnRRwi1p2IzPW1G5eaGESpiQ10inh/4ufpLlaIaI/SDJn07O9\nOQKCAQAD+tITkOPLn39/vRSs5IoElELs/XUoAADrGAEJq4yLw77lCOuBLxKA2QRF\npQ4Vi559ng1/lt2uJAQM0ucVT2LcXkMJiClW8B5vWMsVx3crqjteH3CRBNCZBM09\nJpmdP5XM6cgs9ZTXodubXC+MOqtGFil2pM3IP97v+YURtqbhjopQHdSdUcKwkKqF\ng0MBygNp8z1ysuPUcaSb5Izn5R3lahQUzABTFiiBQCK+NLnTZi1TEG8OUeEqjM0f\nz1WGW89BhHZ8DqIpICvm8QsPmtp4oqdcwZsXtNkleWp7fB0LfUUB92+4TJV4o6R3\nLk9hlOjp5eA9xXlcMwmcQxI/Zg3g\n-----END PRIVATE KEY-----\n`
)

func startFunctionService() {
	http.HandleFunc("/funcs/testsum", CustomFunctionTestSum)

	go http.ListenAndServe("0.0.0.0:12345", nil)

	//We have an assumption that on speedle/sphinx side, certificate is issued by well known CA.
	/*caCert, err := ioutil.ReadFile("client.crt")
	if err != nil {
		log.Fatal(err)
	}*/
	caCertPool := x509.NewCertPool()
	//caCertPool.AppendCertsFromPEM(caCert)

	// Setup HTTPS client
	tlsConfig := &tls.Config{
		ClientCAs: caCertPool,
		//ClientAuth: tls.RequireAndVerifyClientCert,
	}

	server := &http.Server{
		Addr:      "0.0.0.0:23456",
		TLSConfig: tlsConfig,
	}
	server.ListenAndServeTLS("./funcServer.crt", "./funcServer.key")

}

func CustomFunctionTestSum(w http.ResponseWriter, r *http.Request) {
	decoder := json.NewDecoder(r.Body)
	var request ext.CustomerFunctionRequest
	var response ext.CustomerFunctionResponse
	httpSatus := http.StatusOK

	if err := decoder.Decode(&request); err != nil {
		fmt.Println(err)
		response = ext.CustomerFunctionResponse{
			Error: "error decoding request",
		}
		httpSatus = http.StatusBadRequest
	} else {
		fmt.Printf("request = %v\n", request)
		sum := float64(0)
		for index, param := range request.Params {
			fmt.Printf("param %d: value=%v, type=%t\n", index, param, param)
			sum = sum + param.(float64)
		}
		response = ext.CustomerFunctionResponse{
			Result: sum,
		}
	}
	payload, err := json.Marshal(response)
	if err != nil {
		fmt.Println(err)
	} else {
		fmt.Println(response)
		fmt.Println("repsonse=", string(payload))
	}
	w.Header().Set("Content-Type", "application/json; charset=UTF-8")
	w.WriteHeader(httpSatus)
	w.Write(payload)
}

func TestFunctions(t *testing.T) {
	go startFunctionService()

	testCases := []struct {
		condition string
		stream    string
		ctx       adsapi.RequestContext
		want      bool
	}{
		{
			condition: "testsum(1,2) <4",
			stream:    `{"functions":[{"name":"testsum","funcURL":"http://localhost:12345/funcs/testsum"}],"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "testsum(1,2) <4"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 7.99}},
			want:      true,
		},
		{
			condition: "testsum1(1,2) <4",
			stream:    `{"functions":[{"name":"testsum1","funcURL":"https://localhost:23456/funcs/testsum", "CA" : "` + funcServerCert + `"}],"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "testsum1(1,2) <4"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 7.99}},
			want:      true,
		},
		{
			condition: "Sqrt(64) > x",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "Sqrt(64) > x"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 7.99}},
			want:      true,
		},
		{
			condition: "Sqrt(64) > x",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "Sqrt(64) > x"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 8.01}},
			want:      false,
		},
		{
			condition: "Sqrt(x) > 7.99",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "Sqrt(x) > 7.99"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 64}},
			want:      true,
		},
		{
			condition: "Sqrt(x) > 8.01",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "Sqrt(x) > 8.01"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 64}},
			want:      false,
		},
		{
			condition: "Max(-3, x, 5) > y",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "Max(-3, x, 5) > y"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 7, "y": 6}},
			want:      true,
		},
		{
			condition: "Max(-3, x, 5) > y",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "Max(-3, x, 5) > y"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"x": 4, "y": 6}},
			want:      false,
		},

		{
			condition: "IsSubSet(s1,s2)",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(s1,s2)"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s1": []int{1, 3}, "s2": []int{1, 2, 3, 4}}},
			want:      true,
		},
		{
			condition: "IsSubSet(s1,s2)",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(s1,s2)"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s1": []int{1}, "s2": []int{1, 2, 3, 4}}},
			want:      true,
		},
		{
			condition: "IsSubSet(s1,s2)",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(s1,s2)"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s1": []int{1, 5}, "s2": []int{1, 2, 3, 4}}},
			want:      false,
		},
		{
			condition: "IsSubSet(s,('BJ','SH','GZ','SZ'))",
			stream:    `{"services": [{"name": "crm","policies": [{"name": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(s,('BJ','SH','GZ','SZ'))"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s": []string{"GZ", "SH"}}},
			want:      true,
		},
		{
			condition: "IsSubSet(s,('BJ','SH','GZ','SZ'))",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(s,('BJ','SH','GZ','SZ'))"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s": []string{"GZ", "TJ"}}},
			want:      false,
		},
		{
			condition: "IsSubSet(('BJ', 'SZ'), s)",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(('BJ', 'SZ'), s)"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s": []string{"BJ", "GZ", "SH", "SZ"}}},
			want:      true,
		},
		{
			condition: "IsSubSet(('BJ', 'TJ'), s)",
			stream:    `{"services": [{"name": "crm","policies": [{"id": "p1", "effect": "grant", "permissions": [{"resource": "/node1","actions": ["get"]}],"condition": "IsSubSet(('BJ', 'TJ'), s)"}]}]}`,
			ctx:       adsapi.RequestContext{Subject: nil, ServiceName: "crm", Resource: "/node1", Action: "get", Attributes: map[string]interface{}{"s": []string{"BJ", "GZ", "SH", "SZ"}}},
			want:      false,
		},
	}

	for _, tc := range testCases {
		preparePolicyDataInStore([]byte(tc.stream), t)
		eval, err := NewWithStore(conf, testPS)
		if err != nil {
			t.Errorf("error creating evaluator : %v", err)
			continue
		}
		// Run 3 times
		for i := 0; i < 3; i++ {
			got, _, err := eval.IsAllowed(tc.ctx)
			if err != nil {
				t.Errorf("condition: %s, context: %v, error: %v", tc.condition, tc.ctx.Attributes, err)
			}
			if got != tc.want {
				t.Errorf("condition: %s, context: %v, got %v, want %v", tc.condition, tc.ctx.Attributes, got, tc.want)
			}
		}
	}
}
