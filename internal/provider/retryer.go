package provider

import (
	"context"
	"math/rand"
	"strconv"
	"strings"
	"time"

	"github.com/aws/aws-sdk-go-v2/aws"
	"github.com/aws/aws-sdk-go-v2/aws/retry"
	"github.com/hashicorp/terraform-plugin-log/tflog"
)

var _ aws.RetryerV2 = (*Retryer)(nil)

type Retryer struct {
	delayTimeSec    int
	maxRetryCount   int
	ctx             context.Context
	standardRetryer *retry.Standard
}

func NewRetryer(delayTimeSec int, maxRetryCount int, ctx context.Context) *Retryer {
	return &Retryer{
		delayTimeSec:    delayTimeSec,
		maxRetryCount:   maxRetryCount,
		ctx:             ctx,
		standardRetryer: retry.NewStandard(func(o *retry.StandardOptions) {}),
	}
}

func (r *Retryer) IsErrorRetryable(err error) bool {
	isThrottle := strings.Contains(err.Error(), "ThrottlingException")
	tflog.Info(r.ctx, "Retryer.IsErrorRetryable ", map[string]any{"error": err, "isThrottle": strconv.FormatBool(isThrottle)})
	return isThrottle || r.standardRetryer.IsErrorRetryable(err)
}

func (r *Retryer) MaxAttempts() int {
	return r.maxRetryCount
}

func (r *Retryer) RetryDelay(int, error) (time.Duration, error) {
	waitTime := 1
	if r.delayTimeSec > 1 {
		waitTime += rand.Intn(r.delayTimeSec)
	}
	tflog.Info(r.ctx, "Retryer.RetryDelay ", map[string]any{"waitTime": waitTime})
	return time.Duration(waitTime) * time.Second, nil
}

func (r *Retryer) GetRetryToken(context.Context, error) (func(error) error, error) {
	return func(error) error { return nil }, nil
}

func (r *Retryer) GetInitialToken() func(error) error {
	return func(error) error { return nil }
}

func (r *Retryer) GetAttemptToken(context.Context) (func(error) error, error) {
	return func(error) error { return nil }, nil
}
