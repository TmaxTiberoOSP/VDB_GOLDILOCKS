CREATE OR REPLACE PACKAGE BODY "DBMS_VIRTUAL_DATABASE"
IS
    ERROR_PKG_VDB_GOLDILOCKS_DDL_FAIL CONSTANT PLS_INTEGER := -14356;

    PROCEDURE "RAISE_PARAMETER_ERROR" (
        ERROR_CODE      IN PLS_INTEGER,
        ERROR_STR       IN VARCHAR2)
    PRAGMA BUILTIN ('pkg_vdb_goldilocks__raise_parameter_error');

    PROCEDURE "GET_GOLD_CONNECTION_INFO"(
        VDB_IP OUT VARCHAR2,
        VDB_PORT OUT VARCHAR2,
        ID OUT VARCHAR2,
        PASSWORD OUT VARCHAR2)
    PRAGMA BUILTIN('pkg_dbms_virtual_database__get_gold_connection_info');
    
    FUNCTION "EXECUTE_GOLD_DDL_JEPA"(
        DDL IN VARCHAR2,
        VDB_IP IN VARCHAR2,
        VDB_PORT IN VARCHAR2,
        REMOTE_ID IN VARCHAR2,
        REMOTE_PASSWD IN VARCHAR2
    ) RETURN VARCHAR2 IS
    LANGUAGE JAVA NAME 'ExecuteGoldJDBC.ExecuteGold(String, String, String, String, String) return String';

    PROCEDURE "MANAGE_REMOTE_GOLD_OBJECT" (
      DDL IN VARCHAR2)
    PRAGMA BUILTIN ('pkg_dbms_virtual_database__manage_remote_gold_object');

    PROCEDURE "EXECUTE_GOLD_DDL"(DDL IN VARCHAR2)
    IS
        VDB_IP          VARCHAR2(20);
        VDB_PORT        VARCHAR2(20);
        ID              VARCHAR2(100);
        PASSWD          VARCHAR2(100);
        LINK_NAME       VARCHAR2(100);
        ERR_MSG         VARCHAR2(100);
    BEGIN
        COMMIT;
        /* SELECT 해서 가져오기 */
        GET_GOLD_CONNECTION_INFO(VDB_IP, VDB_PORT, ID, PASSWD);
        MANAGE_REMOTE_GOLD_OBJECT(DDL);
        ERR_MSG := EXECUTE_GOLD_DDL_JEPA(DDL, VDB_IP, VDB_PORT, ID, PASSWD);

        IF ERR_MSG = 'DDL SUCCESS' THEN
            COMMIT;
        ELSE
            ROLLBACK;
            RAISE_PARAMETER_ERROR(ERROR_PKG_VDB_GOLDILOCKS_DDL_FAIL, ERR_MSG);
        END IF;
    END;
END;
/