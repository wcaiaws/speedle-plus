package eval

import (
	"regexp"
	"sync"
)

var regexCache sync.Map

func compileRegexCached(pattern string) (*regexp.Regexp, error) {
	if cached, ok := regexCache.Load(pattern); ok {
		return cached.(*regexp.Regexp), nil
	}
	re, err := regexp.Compile(pattern)
	if err != nil {
		return nil, err
	}
	actual, loaded := regexCache.LoadOrStore(pattern, re)
	if loaded {
		return actual.(*regexp.Regexp), nil
	}
	return re, nil
}
