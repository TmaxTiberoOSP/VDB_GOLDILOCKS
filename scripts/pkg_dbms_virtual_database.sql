CREATE OR REPLACE PACKAGE "DBMS_VIRTUAL_DATABASE" 
    AUTHID CURRENT_USER -- what is meaning?
IS
    PROCEDURE "EXECUTE_GOLD_DDL"(
        DDL IN VARCHAR2);
    
    PROCEDURE "REGISTER_GOLD_OBJECT"(
        SCHEMA_NAME IN VARCHAR2, OBJECT_NAME IN VARCHAR2)
    PRAGMA BUILTIN('pkg_dbms_virtual_database__register_gold_object');

    PROCEDURE "UNREGISTER_GOLD_OBJECT"(
        SCHEMA_NAME IN VARCHAR2, OBJECT_NAME IN VARCHAR2)
    PRAGMA BUILTIN('pkg_dbms_virtual_database__unregister_gold_object');

    PROCEDURE "REGISTER_GOLD_CONNECTION_INFO"(
        VDB_IP IN VARCHAR2,
        VDB_PORT IN VARCHAR2,
        ID IN VARCHAR2,
        PASSWD IN VARCHAR2
    )
    PRAGMA BUILTIN('pkg_dbms_virtual_database__register_gold_connection_info');

    PROCEDURE "UNREGISTER_GOLD_CONNECTION_INFO"
    PRAGMA BUILTIN('pkg_dbms_virtual_database__unregister_gold_connection_info');

    PROCEDURE "EXECUTE_TRAIN_DDL"(
    DDL IN VARCHAR2);

    PROCEDURE "REGISTER_TRAIN_CONNECTION_INFO"(
        TRAIN_IP IN VARCHAR2,
        TRAIN_PORT IN VARCHAR2,
        SOURCE_IP IN VARCHAR2,
        SOURCE_PORT IN VARCHAR2,
        ID IN VARCHAR2,
        PASSWD IN VARCHAR2
    )
    PRAGMA BUILTIN('pkg_dbms_virtual_database__register_train_connection_info');

    PROCEDURE "UNREGISTER_TRAIN_CONNECTION_INFO"
    PRAGMA BUILTIN('pkg_dbms_virtual_database__unregister_train_connection_info');

    PROCEDURE "REGISTER_TURBO_CONNECTION_INFO"(
        VDB_IP IN VARCHAR2,
        VDB_PORT IN VARCHAR2,
        ID IN VARCHAR2,
        PASSWD IN VARCHAR2
    )
    PRAGMA BUILTIN('pkg_dbms_virtual_database__register_turbo_connection_info');

    PROCEDURE "UNREGISTER_TURBO_CONNECTION_INFO"
    PRAGMA BUILTIN('pkg_dbms_virtual_database__unregister_turbo_connection_info');

    PROCEDURE "EXECUTE_TURBO_DDL"(
        DDL IN VARCHAR2);
END;
/

CREATE OR REPLACE PUBLIC SYNONYM "DBMS_VIRTUAL_DATABASE" FOR SYS."DBMS_VIRTUAL_DATABASE";
GRANT EXECUTE ON SYS.DBMS_VIRTUAL_DATABASE TO PUBLIC;
