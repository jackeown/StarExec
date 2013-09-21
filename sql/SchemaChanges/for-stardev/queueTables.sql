USE starexec;

CREATE TABLE queue_request (
	user_id INT NOT NULL,
	space_id INT NOT NULL,
	queue_name VARCHAR(64) NOT NULL,
	node_count INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	code VARCHAR(36) NOT NULL,
	message TEXT NOT NULL,
	created TIMESTAMP NOT NULL,	
	PRIMARY KEY (user_id, space_id, queue_name, start_date),
	UNIQUE KEY (code),
	FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
	FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE CASCADE
);

CREATE TABLE queue_reserved (
	space_id INT NOT NULL,
	queue_id INT NOT NULL,
	node_count INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	code VARCHAR(36) NOT NULL,
	PRIMARY KEY (space_id, queue_id, start_date, end_date),
	UNIQUE KEY (code),
	FOREIGN KEY (space_id) REFERENCES spaces(id) ON DELETE CASCADE
);

CREATE TABLE node_reserved (
	node_count INT NOT NULL,
	queue_id INT NOT NULL,
	start_date DATE NOT NULL,
	end_date DATE NOT NULL,
	PRIMARY KEY (queue_id),
	FOREIGN KEY (queue_id) REFERENCES queues(id) ON DELETE CASCADE
);