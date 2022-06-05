zips = ButterflyEvolution_HTML5.zip ButterflyEvolution_Linux.zip ButterflyEvolution_Windows.zip

%.zip: %
	zip -r $@ $(basename $@)

all: $(zips)
