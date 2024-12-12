/**
 * @file    create_vdb.sql
 * @brief   Creating the system generated sequences
 *
 * @author  kwangwon_park
 * @version $Id$
 */

CREATE TABLE _VDB_CONN_INFO (
    VDB_IP      VARCHAR2(20) PRIMARY KEY,
    VDB_PORT    VARCHAR2(20),
    ID          VARCHAR2(100),
    PASSWORD    VARCHAR2(100)
);

CREATE TABLE _VDB_OBJECTS(
	OWNER_ID				VARCHAR2(128),
	REMOTE_OBJECT_OWNER		VARCHAR2(128),
	REMOTE_OBJECT_NAME		VARCHAR2(128),
	REMOTE_OBJECT_TYPE		VARCHAR2(128)
);

CREATE OR REPLACE AND RESOLVE Java SOURCE NAMED "EXECUTE_GOLD_JDBC"
AS
import java.sql.*;
import java.io.*;

public class ExecuteGoldJDBC {
    public static String ExecuteGold(String ddl, String ip, String port,
            String id, String passwd) throws Exception {
		try
		{
			String url = "jdbc:goldilocks://" + ip + ":" + port + "/sundb";

			Connection conn = DriverManager.getConnection(url, id, passwd);
			conn.setAutoCommit(false);
			PreparedStatement pstmt = conn.prepareStatement(ddl);
			if(pstmt.executeUpdate() == 0) {
				conn.commit();
				pstmt.close();
				conn.close();
				return "DDL SUCCESS";
			}

			conn.rollback();
			pstmt.close();
			conn.close();
			return "Input query is not DDL";
		}
		catch (Exception e) {
			String errMsg = e.getMessage();
			switch (errMsg) {
				case "The statement has produced a ResultSet":
					return "Input query is not DDL";
				default:
					return errMsg.substring(0, Math.min(100, errMsg.length()));
			}
		}
	}
}
/
CREATE OR REPLACE PUBLIC SYNONYM EXECUTE_GOLD_JDBC FOR EXECUTE_GOLD_JDBC;

CREATE OR REPLACE VIEW SYSCAT.DBA_VDB_OBJECTS
(OWNER, REMOTE_OBJECT_OWNER, REMOTE_OBJECT_NAME, REMOTE_OBJECT_TYPE)
AS
SELECT U.NAME, V.REMOTE_OBJECT_OWNER, V.REMOTE_OBJECT_NAME, V.REMOTE_OBJECT_TYPE
FROM SYS._DD_USER U, SYS._VDB_OBJECTS V
WHERE U.USER_ID = V.OWNER_ID
;

CREATE OR REPLACE VIEW SYSCAT.ALL_VDB_OBJECTS
AS
SELECT * FROM SYSCAT.DBA_VDB_OBJECTS
WHERE OWNER = USERENV('SCHEMA')
;

CREATE OR REPLACE VIEW SYSCAT.USER_VDB_OBJECTS
AS
SELECT * FROM SYSCAT.DBA_VDB_OBJECTS
WHERE OWNER = USERENV('SCHEMA')
;

CREATE OR REPLACE PUBLIC SYNONYM DBA_VDB_OBJECTS
FOR SYSCAT.DBA_VDB_OBJECTS;
CREATE OR REPLACE PUBLIC SYNONYM ALL_VDB_OBJECTS
FOR SYSCAT.ALL_VDB_OBJECTS;
CREATE OR REPLACE PUBLIC SYNONYM USER_VDB_OBJECTS
FOR SYSCAT.USER_VDB_OBJECTS;

CREATE OR REPLACE VIEW SYSCAT.VDB_CONN_INFO (VDB_IP, VDB_PORT, ID, PASSWORD)
AS
SELECT VDB_IP, VDB_PORT, ID, PASSWORD
FROM SYS._VDB_CONN_INFO;

CREATE OR REPLACE PUBLIC SYNONYM VDB_CONN_INFO FOR SYSCAT.VDB_CONN_INFO;
