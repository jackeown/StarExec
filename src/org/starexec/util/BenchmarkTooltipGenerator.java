package org.starexec.util;

import org.jfree.chart.labels.XYToolTipGenerator;
import org.jfree.data.xy.XYDataset;

import java.util.HashMap;

/**
 * Class used when generating a solver comparison graph for Statistics.java
 * Creates tooltips so that benchmark names are displayed when hovering over
 * data points in the graph
 *
 * @author Eric
 */
public class BenchmarkTooltipGenerator implements XYToolTipGenerator {

	private final HashMap<String, String> names;

	/**
	 * @param data A mapping from series:item in the graph to a benchmark name.
	 */
	public BenchmarkTooltipGenerator(HashMap<String, String> data) {
		names = data;
	}

	@Override
	public String generateToolTip(XYDataset dataset, int series, int item) {
		String key = series + ":" + item;
		return names.get(key);
	}

}
