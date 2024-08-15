public inherited sharing class DatabaseService {
    public List<SObject> query(Query query) {
        if (!query.isTopLevelQuery()) {
            throw new IllegalArgumentException('Query must be a top-level query and not a subselect query');
        }

        String soql = query.toSOQL();
        Map<String, Object> bindVariables = query.getBindVariables();
        AccessLevel accessLevel = query.getAccessLevel();

        if (bindVariables == null) {
            bindVariables = new Map<String, Object>();
        }

        return Database.queryWithBinds(soql, bindVariables, accessLevel);
    }

    public Database.QueryLocator getQueryLocator(Query query) {
        if (!query.isTopLevelQuery()) {
            throw new IllegalArgumentException('Query must be a top-level query and not a subselect query');
        }

        String soql = query.toSOQL();
        Map<String, Object> bindVariables = query.getBindVariables();
        AccessLevel accessLevel = query.getAccessLevel();

        if (bindVariables == null) {
            bindVariables = new Map<String, Object>();
        }

        return Database.getQueryLocatorWithBinds(soql, bindVariables, accessLevel);
    }

    public List<AggregateResult> query(AggregateQuery query) {
        String soql = query.toSOQL();
        Map<String, Object> bindVariables = query.getBindVariables();
        AccessLevel accessLevel = query.getAccessLevel();

        if (bindVariables == null) {
            bindVariables = new Map<String, Object>();
        }

        return Database.queryWithBinds(soql, bindVariables, accessLevel);
    }

    // Returns:
    // For insert/update: List<Database.SaveResult>
    // For upsert: List<Database.UpsertResult>
    // For delete: List<Database.DeleteResult>
    // For undelete: List<Database.UndeleteResult>
    public List<Object> executeDml(Dml dml) {
        Boolean recordsIsEmpty = dml.getRecords() == null || dml.getRecords().isEmpty();
        Boolean recordIdsIsEmpty = dml.getRecordIds() == null || dml.getRecordIds().isEmpty();

        if (recordsIsEmpty && recordIdsIsEmpty) {
            return null;
        }

        List<Object> results;

        Dml.Operation operation = dml.getOperation();
        List<SObject> records = dml.getRecords();
        List<Id> recordIds = dml.getRecordIds();
        SObjectField externalIdField = dml.getExternalIdField();
        Boolean allOrNone = dml.getAllOrNone();
        AccessLevel accessLevel = dml.getAccessLevel();

        switch on operation {
            when INSERT_RECORDS {
                results = Database.insert(records, allOrNone, accessLevel);
            }
            when UPDATE_RECORDS {
                results = Database.update(records, allOrNone, accessLevel);
            }
            when UPSERT_RECORDS {
                if (externalIdField == null) {
                    results = Database.upsert(records, allOrNone, accessLevel);
                } else {
                    results = Database.upsert(records, externalIdField, allOrNone, accessLevel);
                }
            }
            when DELETE_RECORDS {
                if (records != null && !records.isEmpty()) {
                    results = Database.delete(records, allOrNone, accessLevel);
                } else if (recordIds != null && !recordIds.isEmpty()) {
                    results = Database.delete(recordIds, allOrNone, accessLevel);
                }
            }
            when UNDELETE_RECORDS {
                if (records != null && !records.isEmpty()) {
                    results = Database.undelete(records, allOrNone, accessLevel);
                } else if (recordIds != null && !recordIds.isEmpty()) {
                    results = Database.undelete(recordIds, allOrNone, accessLevel);
                }
            }
        }

        return results;
    }
}