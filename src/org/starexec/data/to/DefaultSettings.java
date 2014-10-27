package org.starexec.data.to;

import org.starexec.data.database.Benchmarks;
import org.starexec.data.database.Processors;
import org.starexec.data.database.Solvers;
import org.starexec.data.to.JobStatus.JobStatusCode;
import org.starexec.util.Util;

public class DefaultSettings extends Identifiable {
	public enum SettingType {
		USER(0), COMMUNITY(1);
		
	    private final int value;
		private SettingType(int value) {
			this.value = value;
		}

		public int getValue() {
			return value;
		}
		
	public static SettingType toStatusCode(int code) {
			
		    switch (code) {
		    case 0:
		    	return SettingType.USER;
		    case 1:
		    	return SettingType.COMMUNITY;
		
		}
		return null;
	}
}

	private Integer primId;
	private Integer preProcessorId;
	private Integer postProcessorId;
	private Integer benchProcessorId;
	private Integer benchId;
	private Integer solverId;
	private int wallclockTimeout;
	private int cpuTimeout;
	private long maxMemory;
	private boolean dependenciesEnabled;
	private String name;
	private SettingType type;
	/**
	 * Initializes a new DefaultSettings object with every field set to the system default.
	 */
	public DefaultSettings() {
		postProcessorId=null;
		wallclockTimeout=10;
		cpuTimeout=10;
		benchId=null;
		solverId=null;
		maxMemory=1073741824;
		preProcessorId=null;
		name="settings";
		dependenciesEnabled=false;
		benchProcessorId=Processors.getNoTypeProcessor().getId();
		type=null;
		setPrimId(-1);
	}
	public void setPreProcessorId(int preProcessorId) {
		this.preProcessorId = preProcessorId;
	}
	public Integer getPreProcessorId() {
		return preProcessorId;
	}
	public void setPostProcessorId(int postProcessorId) {
		this.postProcessorId = postProcessorId;
	}
	public Integer getPostProcessorId() {
		return postProcessorId;
	}
	public void setBenchProcessorId(int benchProcessorId) {
		this.benchProcessorId = benchProcessorId;
	}
	public Integer getBenchProcessorId() {
		return benchProcessorId;
	}
	public void setBenchId(int benchId) {
		this.benchId = benchId;
	}
	public Integer getBenchId() {
		return benchId;
	}
	public void setSolverId(int solverId) {
		this.solverId = solverId;
	}
	public Integer getSolverId() {
		return solverId;
	}
	public void setWallclockTimeout(int wallclockTimeout) {
		this.wallclockTimeout = wallclockTimeout;
	}
	public int getWallclockTimeout() {
		return wallclockTimeout;
	}
	public void setCpuTimeout(int cpuTimeout) {
		this.cpuTimeout = cpuTimeout;
	}
	public int getCpuTimeout() {
		return cpuTimeout;
	}
	public void setMaxMemory(long mem) {
		this.maxMemory = mem;
	}
	public long getMaxMemory() {
		return this.maxMemory;
	}
	public double getRoundedMaxMemoryAsDouble() {
		return Util.bytesToGigabytes(maxMemory);
	}
	public void setDependenciesEnabled(boolean dependenciesEnabled) {
		this.dependenciesEnabled = dependenciesEnabled;
	}
	public boolean isDependenciesEnabled() {
		return dependenciesEnabled;
	}
	public void setName(String name) {
		this.name = name;
	}
	public String getName() {
		
		return name;
	}

	
	public String getSolverName() {
		if (solverId==null) {
			return "None";
		}
		Solver s=Solvers.get(solverId);
		if (s==null) {
			return "None";
		}
		return s.getName();
	}
	
	public String getBenchmarkName() {
		if (benchId==null) {
			return "None";
		}
		Benchmark b=Benchmarks.get(benchId);
		if (b==null) {
			return "None";
		}
		return b.getName();
		
	}
	public void setPrimId(Integer primId) {
		this.primId = primId;
	}
	public Integer getPrimId() {
		return primId;
	}
	public void setType(SettingType type) {
		this.type = type;
	}
	public void setType(int type) {
		this.type = SettingType.toStatusCode(type);
	}
	public SettingType getType() {
		return type;
	}
	
	/**
	 * Checks for deep equality between this object and another DefaultSettings profile
	 */
	@Override
	public boolean equals(Object s) {
		if (!(s instanceof DefaultSettings)) {
            return false;
		}
		DefaultSettings set=(DefaultSettings) s;


		return (this.getId()==set.getId() &&
				Util.stringsEqual(this.getName(), set.getName()) &&
				this.getPrimId()==set.getPrimId() &&
				this.getPreProcessorId()==set.getPreProcessorId() &&
				this.getBenchProcessorId()==set.getBenchProcessorId() &&
				this.getPostProcessorId()==set.getPostProcessorId() &&
				this.getCpuTimeout()==set.getCpuTimeout() &&
				this.getWallclockTimeout()==set.getWallclockTimeout()&&
				this.getMaxMemory()==set.getMaxMemory());
		
	}
}
