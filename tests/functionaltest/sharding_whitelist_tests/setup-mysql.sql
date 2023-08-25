DROP TABLE IF EXISTS hera_shard_map;
CREATE TABLE hera_shard_map (SCUTTLE_ID INT, SHARD_ID INT, STATUS CHAR(1), READ_STATUS CHAR(1), WRITE_STATUS CHAR(1), REMARKS VARCHAR(500));

drop procedure if exists populate_shard_map;

delimiter #
create procedure populate_shard_map()
begin

declare v_max int unsigned default 128;
declare v_counter int unsigned default 0;

  while v_counter < v_max do
    INSERT INTO hera_shard_map VALUES (v_counter, mod(v_counter, 5),'Y','Y','Y','Initial');
    set v_counter=v_counter+1;
  end while;
  commit;
end #

delimiter ;

call populate_shard_map();


drop table IF EXISTS hera_whitelist;
create table hera_whitelist (SHARD_KEY int NOT NULL, SHARD_ID int NOT NULL, ENABLE CHAR(1), READ_STATUS CHAR(1), WRITE_STATUS CHAR(1), REMARKS VARCHAR(500));
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 000, 0, 'Y', 'Y' );
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 111, 1, 'Y', 'Y' );
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 222, 2, 'Y', 'Y' );
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 333, 3, 'Y', 'Y' );
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 444, 4, 'Y', 'Y' );
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 555, 5, 'Y', 'Y' );
INSERT INTO hera_whitelist ( enable, shard_key, shard_id, read_status, write_status ) VALUES ( 'Y', 1234, 4, 'Y', 'Y' );


