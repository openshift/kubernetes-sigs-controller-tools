package markers

import (
	"os"
	"strings"

	"k8s.io/apimachinery/pkg/util/sets"
	"sigs.k8s.io/controller-tools/pkg/markers"
)

var RequiredFeatureSets = sets.NewString()

func init() {
	featureSet := os.Getenv("OPENSHIFT_REQUIRED_FEATURESET")
	if len(featureSet) == 0 {
		return
	}

	for _, curr := range strings.Split(featureSet, ",") {
		RequiredFeatureSets.Insert(curr)
	}
}

const OpenShiftFeatureSetMarkerName = "openshift:enable:FeatureSets"

func init() {
	FieldOnlyMarkers = append(FieldOnlyMarkers,
		must(markers.MakeDefinition(OpenShiftFeatureSetMarkerName, markers.DescribesField, []string{})).
			WithHelp(markers.SimpleHelp("OpenShift", "specifies the FeatureSet that is required to generate this field.")),
	)
}
