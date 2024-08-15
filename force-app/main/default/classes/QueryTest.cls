// Suppressing MethodNamingConventions because naming format is methodBeingTested_testScenario_expectedResult
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest(IsParallel=true)
private without sharing class QueryTest {
    @IsTest
    static void query_passSObjectType_objectTypePopulated() {
        SObjectType objectType = Account.SObjectType;

        Test.startTest();
        Query queryInstance = new Query(objectType);
        Test.stopTest();

        Assert.areEqual(objectType, queryInstance.objectType, 'Expected the objectType to be ' + objectType);
    }

    @IsTest
    static void query_passSubselectRelationshipName_subselectRelationshipNamePopulated() {
        String subselectRelationshipName = 'Contacts';

        Test.startTest();
        Query queryInstance = new Query(subselectRelationshipName);
        Test.stopTest();

        Assert.areEqual(
            subselectRelationshipName,
            queryInstance.subselectRelationshipName,
            'Expected the subselectRelationshipName to be populated'
        );
    }

    @IsTest
    static void withSelectFields_passSetOfSObjectFields_selectFieldsPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        Set<SObjectField> selectFields = new Set<SObjectField>{ Account.Id, Account.Name };

        Test.startTest();
        queryInstance.withSelectFields(selectFields);
        Test.stopTest();

        Assert.areEqual(selectFields, queryInstance.selectFields, 'Expected the selectFields to be populated');
    }

    @IsTest
    static void withLookupFields_passMapOfLookupFields_lookupFieldsPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        Map<SObjectField, Set<SObjectField>> lookupFields = new Map<SObjectField, Set<SObjectField>>{
            Account.ParentId => new Set<SObjectField>{ Account.Id, Account.Name }
        };

        Test.startTest();
        queryInstance.withLookupFields(lookupFields);
        Test.stopTest();

        Assert.areEqual(lookupFields, queryInstance.lookupFields, 'Expected the lookupFields to be populated');
    }

    @IsTest
    static void withSubselectQuery_passSubselectQuery_subselectQueryPopulated() {
        Query parentQuery = new Query(Account.SObjectType);
        Query subselectQuery = new Query('Contacts')
            .withSelectFields(new Set<SObjectField>{ Contact.Id, Contact.Name });

        Test.startTest();
        parentQuery.withSubselectQuery(subselectQuery);
        Test.stopTest();

        Assert.areEqual(subselectQuery, parentQuery.subselectQuery, 'Expected the subselectQuery to be populated');
    }

    @IsTest
    static void withSubselectQuery_passTopLevelQuery_exceptionThrown() {
        Query parentQuery = new Query(Account.SObjectType);
        Query subselectQuery = new Query(Contact.SObjectType);

        Test.startTest();
        try {
            parentQuery.withSubselectQuery(subselectQuery);
            Assert.fail('The expected exception was not thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'The expected exception was not thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void withWhereClause_passWhereClauseWithoutBinds_whereClausePopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        String whereClause = 'Name = \'Test\'';

        Test.startTest();
        queryInstance.withWhereClause(whereClause);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.isNull(queryInstance.bindVariables, 'Expected the bindVariables to be null');
    }

    @IsTest
    static void withWhereClause_passWhereClauseWithBinds_whereClauseAndBindsPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        String whereClause = 'Name = :accountName';
        Map<String, Object> bindVariables = new Map<String, Object>{ 'accountName' => 'Test' };

        Test.startTest();
        queryInstance.withWhereClause(whereClause, bindVariables);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.areEqual(bindVariables, queryInstance.bindVariables, 'Expected the bindVariables to be populated');
    }

    @IsTest
    static void withWhereClause_complexWhereClauseWithBinds_whereClauseAndBindVariablesPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        String whereClause = 'Name = :name AND CreatedDate > :createdDate';
        Map<String, Object> bindVariables = new Map<String, Object>{
            'name' => 'Test',
            'createdDate' => Date.today().addDays(-30)
        };

        Test.startTest();
        queryInstance.withWhereClause(whereClause, bindVariables);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.areEqual(
            bindVariables.size(),
            queryInstance.bindVariables.size(),
            'Expected the bindVariables size to be equal'
        );
        Assert.areEqual(
            bindVariables.get('name'),
            queryInstance.bindVariables.get('name'),
            'Expected the bindVariable for name to be equal'
        );
        Assert.areEqual(
            bindVariables.get('createdDate'),
            queryInstance.bindVariables.get('createdDate'),
            'Expected the bindVariable for createdDate to be equal'
        );
    }

    @IsTest
    static void withWhereClause_nullBindVariables_whereClausePopulatedBindVariablesNull() {
        Query queryInstance = new Query(Account.SObjectType);
        String whereClause = 'Name = :name';

        Test.startTest();
        queryInstance.withWhereClause(whereClause, null);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.isNull(queryInstance.bindVariables, 'Expected the bindVariables to be null');
    }

    @IsTest
    static void withWhereClause_passWhereClauseWithSingleBind_whereClauseAndSingleBindPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        String whereClause = 'Name = :name';
        String bindVariableName = 'name';
        String bindVariableValue = 'Test';

        Test.startTest();
        queryInstance.withWhereClause(whereClause, bindVariableName, bindVariableValue);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.isNotNull(queryInstance.bindVariables, 'Expected the bindVariables to be populated');
        Assert.areEqual(
            bindVariableValue,
            queryInstance.bindVariables.get(bindVariableName),
            'Expected the bindVariable to be correctly populated'
        );
    }

    @IsTest
    static void withOrderBy_passSObjectFieldWithoutDirection_orderByFieldPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        SObjectField orderByField = Account.Name;
        Query.OrderByClause orderByClause = new Query.OrderByClause(orderByField);

        Test.startTest();
        queryInstance.withOrderBy(orderByClause);
        Test.stopTest();

        Assert.areEqual(
            orderByField,
            queryInstance.orderByClauses.get(0).orderByField,
            'Expected the orderByField to be populated'
        );
        Assert.areEqual(
            Query.DEFAULT_ORDER_BY_DIRECTION,
            queryInstance.orderByClauses.get(0).orderByDirection,
            'Expected the orderByDirection to use the default value'
        );
    }

    @IsTest
    static void withOrderBy_passSObjectFieldAndDirection_orderByFieldAndOrderByDirectionPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        SObjectField orderByField = Account.Name;
        Query.SortOrder orderByDirection = Query.SortOrder.ASCENDING;
        Query.OrderByClause orderByClause = new Query.OrderByClause(orderByField)
            .withOrderByDirection(orderByDirection);

        Test.startTest();
        queryInstance.withOrderBy(orderByClause);
        Test.stopTest();

        Assert.areEqual(
            orderByField,
            queryInstance.orderByClauses.get(0).orderByField,
            'Expected the orderByField to be populated'
        );
        Assert.areEqual(
            orderByDirection,
            queryInstance.orderByClauses.get(0).orderByDirection,
            'Expected the orderByDirection to be populated'
        );
    }

    @IsTest
    static void withOrderBy_defaultSortOrder_appliedCorrectly() {
        Query queryInstance = new Query(Account.SObjectType);
        SObjectField orderByField = Account.Name;

        Test.startTest();
        queryInstance.withOrderBy(new Query.OrderByClause(orderByField));
        Test.stopTest();

        Assert.areEqual(
            Query.DEFAULT_ORDER_BY_DIRECTION,
            queryInstance.orderByClauses.get(0).orderByDirection,
            'Expected the default sort order to be applied'
        );
    }

    @IsTest
    static void withOrderBy_passOrderByField_orderByClausePopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        SObjectField orderByField = Account.Name;

        Test.startTest();
        queryInstance.withOrderBy(orderByField);
        Test.stopTest();

        Assert.isNotNull(queryInstance.orderByClauses, 'Expected the orderByClauses to be populated');
        Assert.areEqual(
            orderByField,
            queryInstance.orderByClauses.get(0).orderByField,
            'Expected the orderByField to be correctly populated'
        );
        Assert.areEqual(
            Query.DEFAULT_ORDER_BY_DIRECTION,
            queryInstance.orderByClauses.get(0).orderByDirection,
            'Expected the default orderByDirection to be used'
        );
    }

    @IsTest
    static void withOrderBy_passListOfOrderByFields_orderByClausesPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        List<SObjectField> orderByFields = new List<SObjectField>{ Account.Name, Account.CreatedDate };

        Test.startTest();
        queryInstance.withOrderBy(orderByFields);
        Test.stopTest();

        Assert.isNotNull(queryInstance.orderByClauses, 'Expected the orderByClauses to be populated');
        Assert.areEqual(
            orderByFields.size(),
            queryInstance.orderByClauses.size(),
            'Expected the number of orderByClauses to match the number of orderByFields'
        );
        for (Integer i = 0; i < orderByFields.size(); i++) {
            Assert.areEqual(
                orderByFields.get(i),
                queryInstance.orderByClauses.get(i).orderByField,
                'Expected the orderByField to be correctly populated'
            );
            Assert.areEqual(
                Query.DEFAULT_ORDER_BY_DIRECTION,
                queryInstance.orderByClauses.get(i).orderByDirection,
                'Expected the default orderByDirection to be used'
            );
        }
    }

    @IsTest
    static void withLimit_passLimitLessThanMax_rowLimitPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        Integer rowLimit = 200;

        Test.startTest();
        queryInstance.withLimit(rowLimit);
        Test.stopTest();

        Assert.areEqual(rowLimit, queryInstance.rowLimit, 'Expected the rowLimit to be populated');
    }

    @IsTest
    static void withLimit_passLimitGreaterThanMax_exceptionThrown() {
        Query queryInstance = new Query(Account.SObjectType);
        Integer rowLimit = 50001;

        Test.startTest();
        try {
            queryInstance.withLimit(rowLimit);
            Assert.fail('The expected exception was not thrown');
        } catch (Exception e) {
            Assert.isInstanceOfType(e, IllegalArgumentException.class, 'The expected exception was not thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void withForUpdate_callMethod_forUpdateSetToTrue() {
        Query queryInstance = new Query(Account.SObjectType);

        Test.startTest();
        queryInstance.withForUpdate();
        Test.stopTest();

        Assert.isTrue(queryInstance.forUpdate, 'Expected the forUpdate to be set to true');
    }

    @IsTest
    static void withAccessLevel_passAccessLevel_accessLevelPopulated() {
        Query queryInstance = new Query(Account.SObjectType);
        AccessLevel accessLevel = AccessLevel.SYSTEM_MODE;

        Test.startTest();
        queryInstance.withAccessLevel(accessLevel);
        Test.stopTest();

        Assert.areEqual(accessLevel, queryInstance.accessLevel, 'Expected the accessLevel to be populated');
    }

    @IsTest
    static void toSOQL_variablesNotPopulated_returnBasicQuery() {
        Query queryInstance = new Query(Account.SObjectType);

        Test.startTest();
        String soql = queryInstance.toSOQL();
        Test.stopTest();

        Assert.areEqual('SELECT Id FROM Account', soql, 'Expected the basic query returned');
    }

    @IsTest
    static void toSOQL_variablesPopulated_returnFullQuery() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.selectFields = new Set<SObjectField>{ Account.Id, Account.Name };
        queryInstance.lookupFields = new Map<SObjectField, Set<SObjectField>>{
            Account.ParentId => new Set<SObjectField>{ Account.Id, Account.Name }
        };
        queryInstance.whereClause = 'Name != NULL';
        queryInstance.orderByClauses = new List<Query.OrderByClause>{
            new Query.OrderByClause(Account.Name).withOrderByDirection(Query.SortOrder.ASCENDING)
        };
        queryInstance.rowLimit = 200;

        Test.startTest();
        String soql = queryInstance.toSOQL();
        Test.stopTest();

        String expectedSoql =
            'SELECT Id, Name, Parent.Id, Parent.Name ' +
            'FROM Account ' +
            'WHERE Name != NULL ' +
            'ORDER BY Name ASC NULLS FIRST ' +
            'LIMIT 200';

        Assert.areEqual(expectedSoql, soql, 'Expected the full query returned');
    }

    @IsTest
    static void getBindVariables_bindVariablesPopulated_returnBindVariables() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.bindVariables = new Map<String, Object>{ 'accountName' => 'Test' };

        Test.startTest();
        Map<String, Object> bindVariables = queryInstance.getBindVariables();
        Test.stopTest();

        Assert.areEqual(queryInstance.bindVariables, bindVariables, 'Expected the bindVariables to be returned');
    }

    @IsTest
    static void getAccessLevel_accessLevelNull_returnDefaultAccessLevel() {
        Query queryInstance = new Query(Account.SObjectType);

        Test.startTest();
        AccessLevel accessLevel = queryInstance.getAccessLevel();
        Test.stopTest();

        Assert.areEqual(
            Query.DEFAULT_ACCESS_LEVEL,
            accessLevel,
            'Expected the accessLevel to be equal to the default value'
        );
    }

    @IsTest
    static void getAccessLevel_accessLevelPopulated_returnAccessLevel() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.accessLevel = AccessLevel.SYSTEM_MODE;

        Test.startTest();
        AccessLevel accessLevel = queryInstance.getAccessLevel();
        Test.stopTest();

        Assert.areEqual(queryInstance.accessLevel, accessLevel, 'Expected the accessLevel to be returned');
    }

    @IsTest
    static void isSubselectQuery_subselectRelationshipNameNotNull_returnTrue() {
        Query queryInstance = new Query('Contacts');

        Test.startTest();
        Boolean isSubselect = queryInstance.isSubselectQuery();
        Test.stopTest();

        Assert.isTrue(isSubselect, 'Expected the query to be identified as a subselect query');
    }

    @IsTest
    static void isSubselectQuery_subselectRelationshipNameNull_returnFalse() {
        Query queryInstance = new Query(Account.SObjectType);

        Test.startTest();
        Boolean isSubselect = queryInstance.isSubselectQuery();
        Test.stopTest();

        Assert.isFalse(isSubselect, 'Expected the query not to be identified as a subselect query');
    }

    //================================================================================
    // Tests for helpers
    //================================================================================

    @IsTest
    static void getSelectStatement_selectFieldsEmpty_returnDefaultSelectFields() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.selectFields = new Set<SObjectField>();

        Test.startTest();
        String selectStatement = queryInstance.getSelectStatement();
        Test.stopTest();

        Assert.areEqual(
            'SELECT ' + Query.DEFAULT_SELECT_FIELDS,
            selectStatement,
            'Expected the selectStatement to contain only ' + Query.DEFAULT_SELECT_FIELDS
        );
    }

    @IsTest
    static void getSelectStatement_selectFieldsPopulated_returnSelectFields() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.selectFields = new Set<SObjectField>{ Account.Id, Account.Name };

        Test.startTest();
        String selectStatement = queryInstance.getSelectStatement();
        Test.stopTest();

        Assert.areEqual('SELECT Id, Name', selectStatement, 'Expected the selectStatement to contain Id and Name');
    }

    @IsTest
    static void getSelectLookupFields_lookUpFieldsEmpty_returnBlank() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.lookupFields = new Map<SObjectField, Set<SObjectField>>();

        Test.startTest();
        String selectLookupFields = queryInstance.getSelectLookupFields();
        Test.stopTest();

        Assert.isTrue(String.isBlank(selectLookupFields), 'Expected the selectStatement to be blank');
    }

    @IsTest
    static void getSelectLookupFields_lookUpFieldsPopulated_returnLookupFields() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.lookupFields = new Map<SObjectField, Set<SObjectField>>{
            Account.ParentId => new Set<SObjectField>{ Account.Id, Account.Name }
        };

        Test.startTest();
        String selectLookupFields = queryInstance.getSelectLookupFields();
        Test.stopTest();

        Assert.areEqual(
            ', Parent.Id, Parent.Name',
            selectLookupFields,
            'Expected the selectLookupFields to contain the Parent Id and Name'
        );
    }

    @IsTest
    static void getFromStatement_objectTypePopulated_returnFromSObjectType() {
        Query queryInstance = new Query(Account.SObjectType);

        Test.startTest();
        String fromStatement = queryInstance.getFromStatement();
        Test.stopTest();

        Assert.areEqual(' FROM Account', fromStatement, 'Expected the fromStatement to contain Account object');
    }

    @IsTest
    static void getFromStatement_isSubselectQuery_returnFromSubselect() {
        Query queryInstance = new Query('Contacts');

        Test.startTest();
        String fromStatement = queryInstance.getFromStatement();
        Test.stopTest();

        Assert.areEqual(
            ' FROM Contacts',
            fromStatement,
            'Expected the fromStatement to contain subselect relationship'
        );
    }

    @IsTest
    static void getWhereStatement_whereClauseNull_returnBlank() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.whereClause = null;

        Test.startTest();
        String whereStatement = queryInstance.getWhereStatement();
        Test.stopTest();

        Assert.isTrue(String.isBlank(whereStatement), 'Expected the whereStatement to be blank');
    }

    @IsTest
    static void getWhereStatement_whereClauseBlank_returnBlank() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.whereClause = '';

        Test.startTest();
        String whereStatement = queryInstance.getWhereStatement();
        Test.stopTest();

        Assert.isTrue(String.isBlank(whereStatement), 'Expected the whereStatement to be blank');
    }

    @IsTest
    static void getWhereStatement_whereClausePopulated_returnWhereStatement() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.whereClause = 'Name != NULL';

        Test.startTest();
        String whereStatement = queryInstance.getWhereStatement();
        Test.stopTest();

        Assert.areEqual(
            ' WHERE ' + queryInstance.whereClause,
            whereStatement,
            'Expected the whereStatement to contain ' + queryInstance.whereClause
        );
    }

    @IsTest
    static void getOrderByStatement_orderByFieldEmpty_returnBlank() {
        Query queryInstance = new Query(Account.SObjectType);

        Test.startTest();
        String orderByStatement = queryInstance.getOrderByStatement();
        Test.stopTest();

        Assert.isTrue(String.isBlank(orderByStatement), 'Expected the orderByStatement to be blank');
    }

    @IsTest
    static void getOrderByStatement_orderByFieldPopulatedAndOrderByDirectionAscending_returnOrderByStatementAsc() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.orderByClauses = new List<Query.OrderByClause>{
            new Query.OrderByClause(Account.Name).withOrderByDirection(Query.SortOrder.ASCENDING)
        };

        Test.startTest();
        String orderByStatement = queryInstance.getOrderByStatement();
        Test.stopTest();

        Assert.areEqual(
            ' ORDER BY Name ASC NULLS FIRST',
            orderByStatement,
            'Expected the orderByStatement to be ordered by Name ascending'
        );
    }

    @IsTest
    static void getOrderByStatement_orderByFieldPopulatedAndOrderByDirectionDescending_returnOrderByStatementDesc() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.orderByClauses = new List<Query.OrderByClause>{
            new Query.OrderByClause(Account.Name).withOrderByDirection(Query.SortOrder.DESCENDING)
        };

        Test.startTest();
        String orderByStatement = queryInstance.getOrderByStatement();
        Test.stopTest();

        Assert.areEqual(
            ' ORDER BY Name DESC NULLS FIRST',
            orderByStatement,
            'Expected the orderByStatement to be ordered by Name descending'
        );
    }

    @IsTest
    static void getLimitStatement_rowLimitNull_returnBlank() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.rowLimit = null;

        Test.startTest();
        String limitStatement = queryInstance.getLimitStatement();
        Test.stopTest();

        Assert.isTrue(String.isBlank(limitStatement), 'Expected the limitStatement to be blank');
    }

    @IsTest
    static void getLimitStatement_rowLimitLessThanZero_returnBlank() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.rowLimit = -1;

        Test.startTest();
        String limitStatement = queryInstance.getLimitStatement();
        Test.stopTest();

        Assert.isTrue(String.isBlank(limitStatement), 'Expected the limitStatement to be blank');
    }

    @IsTest
    static void getLimitStatement_rowLimitPopulated_returnLimitStatement() {
        Query queryInstance = new Query(Account.SObjectType);
        queryInstance.rowLimit = 200;

        Test.startTest();
        String limitStatement = queryInstance.getLimitStatement();
        Test.stopTest();

        Assert.areEqual(
            ' LIMIT ' + queryInstance.rowLimit,
            limitStatement,
            'Expected the limitStatement to be ' + queryInstance.rowLimit
        );
    }

    @IsTest
    static void orderByClause_passOrderByField_instanceConstructed() {
        SObjectField orderByField = Account.Name;

        Test.startTest();
        Query.OrderByClause orderByClause = new Query.OrderByClause(orderByField);
        Test.stopTest();

        Assert.isNotNull(orderByClause, 'Expected an OrderByClause instance');
        Assert.areEqual(orderByField, orderByClause.orderByField, 'Expected the orderByField to be populated');
        Assert.areEqual(
            Query.DEFAULT_ORDER_BY_DIRECTION,
            orderByClause.orderByDirection,
            'Expected the orderByDirection to use the default value'
        );
    }

    @IsTest
    static void withOrderByDirection_passOrderByDirection_orderByDirectionPopulated() {
        SObjectField orderByField = Account.Name;
        Query.SortOrder orderByDirection = Query.SortOrder.DESCENDING;
        Query.OrderByClause orderByClause = new Query.OrderByClause(orderByField);

        Test.startTest();
        orderByClause.withOrderByDirection(orderByDirection);
        Test.stopTest();

        Assert.areEqual(
            orderByDirection,
            orderByClause.orderByDirection,
            'Expected the orderByDirection to be populated'
        );
    }

    @IsTest
    static void withOrderByNulls_passOrderByNulls_orderByNullsPopulated() {
        SObjectField orderByField = Account.Name;
        Query.NullsOrder orderByNulls = Query.NullsOrder.LAST;
        Query.OrderByClause orderByClause = new Query.OrderByClause(orderByField);

        Test.startTest();
        orderByClause.withOrderByNulls(orderByNulls);
        Test.stopTest();

        Assert.areEqual(orderByNulls, orderByClause.orderByNulls, 'Expected the orderByNulls to be populated');
    }
}