// Suppressing MethodNamingConventions because naming format is methodBeingTested_testScenario_expectedResult
@SuppressWarnings('PMD.MethodNamingConventions')
@IsTest(IsParallel=true)
private without sharing class AggregateQueryTest {
    @IsTest
    static void constructor_passSObjectType_objectTypePopulated() {
        SObjectType objectType = Account.SObjectType;

        Test.startTest();
        AggregateQuery queryInstance = new AggregateQuery(objectType);
        Test.stopTest();

        Assert.isNotNull(queryInstance, 'Expected the queryInstance to be initialized');
        Assert.areEqual(objectType, queryInstance.objectType, 'Expected the objectType to be populated');
    }

    @IsTest
    static void withSelectStatement_passSelectStatement_selectStatementPopulated() {
        String selectStatement = 'COUNT(Id)';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withSelectStatement(selectStatement);
        Test.stopTest();

        Assert.areEqual(selectStatement, queryInstance.selectStatement, 'Expected the selectStatement to be populated');
    }

    @IsTest
    static void withWhereClause_passWhereClauseWithoutBinds_whereClausePopulated() {
        String whereClause = 'Name = \'Test\'';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withWhereClause(whereClause);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.isNull(queryInstance.bindVariables, 'Expected the bindVariables to be null');
    }

    @IsTest
    static void withWhereClause_passWhereClauseWithBinds_whereClauseAndBindsPopulated() {
        String whereClause = 'Name = :accountName';
        Map<String, Object> bindVariables = new Map<String, Object>{ 'accountName' => 'Test' };
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withWhereClause(whereClause, bindVariables);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.areEqual(bindVariables, queryInstance.bindVariables, 'Expected the bindVariables to be populated');
    }

    @IsTest
    static void withWhereClause_passWhereClauseWithBindVariables_whereClauseAndBindVariablePopulated() {
        String whereClause = 'Name = :accountName';
        String bindVariableName = 'accountName';
        String bindVariableValue = 'Test';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withWhereClause(whereClause, bindVariableName, bindVariableValue);
        Test.stopTest();

        Assert.areEqual(whereClause, queryInstance.whereClause, 'Expected the whereClause to be populated');
        Assert.areEqual(
            new Map<String, Object>{ bindVariableName => bindVariableValue },
            queryInstance.bindVariables,
            'Expected the bindVariables to be populated'
        );
    }

    @IsTest
    static void withOtherStatements_passOtherStatements_otherStatementsPopulated() {
        String otherStatements = 'GROUP BY Name';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withOtherStatements(otherStatements);
        Test.stopTest();

        Assert.areEqual(otherStatements, queryInstance.otherStatements, 'Expected the otherStatements to be populated');
    }

    @IsTest
    static void withAccessLevel_passAccessLevel_accessLevelPopulated() {
        AccessLevel accessLevel = AccessLevel.SYSTEM_MODE;
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withAccessLevel(accessLevel);
        Test.stopTest();

        Assert.areEqual(accessLevel, queryInstance.accessLevel, 'Expected the accessLevel to be populated');
    }

    @IsTest
    static void toSOQL_variablesNotPopulated_returnBasicQuery() {
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        String soql = queryInstance.toSOQL();
        Test.stopTest();

        Assert.areEqual('SELECT Id FROM Account', soql, 'Expected the basic query returned');
    }

    @IsTest
    static void toSOQL_variablesPopulated_returnFullQuery() {
        String selectStatement = 'COUNT(Id)';
        String whereClause = 'Name != NULL';
        String otherStatements = 'GROUP BY Name';

        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType)
            .withSelectStatement(selectStatement)
            .withWhereClause(whereClause)
            .withOtherStatements(otherStatements);

        Test.startTest();
        String soql = queryInstance.toSOQL();
        Test.stopTest();

        String expectedSoql = 'SELECT COUNT(Id) FROM Account WHERE Name != NULL GROUP BY Name';
        Assert.areEqual(expectedSoql, soql, 'Expected the full query returned');
    }

    @IsTest
    static void getBindVariables_bindVariablesPopulated_returnBindVariables() {
        Map<String, Object> bindVariables = new Map<String, Object>{ 'accountName' => 'Test' };
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType)
            .withWhereClause('Name = :accountName', bindVariables);

        Test.startTest();
        Map<String, Object> returnedBindVariables = queryInstance.getBindVariables();
        Test.stopTest();

        Assert.areEqual(bindVariables, returnedBindVariables, 'Expected the bindVariables to be returned');
    }

    @IsTest
    static void getAccessLevel_accessLevelNull_returnDefaultAccessLevel() {
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        AccessLevel accessLevel = queryInstance.getAccessLevel();
        Test.stopTest();

        Assert.areEqual(
            AggregateQuery.DEFAULT_ACCESS_LEVEL,
            accessLevel,
            'Expected the accessLevel to be equal to the default value'
        );
    }

    @IsTest
    static void getAccessLevel_accessLevelPopulated_returnAccessLevel() {
        AccessLevel accessLevel = AccessLevel.SYSTEM_MODE;
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType).withAccessLevel(accessLevel);

        Test.startTest();
        AccessLevel returnedAccessLevel = queryInstance.getAccessLevel();
        Test.stopTest();

        Assert.areEqual(accessLevel, returnedAccessLevel, 'Expected the accessLevel to be returned');
    }

    @IsTest
    static void getSelectStatement_selectStatementNull_returnDefaultSelectFields() {
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        String selectStatement = queryInstance.getSelectStatement();
        Test.stopTest();

        Assert.areEqual('SELECT Id', selectStatement, 'Expected the selectStatement to contain only Id');
    }

    @IsTest
    static void getSelectStatement_selectStatementPopulated_returnSelectFields() {
        String selectStatement = 'COUNT(Id)';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType).withSelectStatement(selectStatement);

        Test.startTest();
        String returnedSelectStatement = queryInstance.getSelectStatement();
        Test.stopTest();

        Assert.areEqual(
            'SELECT ' + selectStatement,
            returnedSelectStatement,
            'Expected the selectStatement to be ' + selectStatement
        );
    }

    @IsTest
    static void getFromStatement_objectTypePopulated_returnFromSObjectType() {
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        String fromStatement = queryInstance.getFromStatement();
        Test.stopTest();

        Assert.areEqual(' FROM Account', fromStatement, 'Expected the fromStatement to contain Account object');
    }

    @IsTest
    static void getWhereStatement_whereClauseNull_returnBlank() {
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        String whereStatement = queryInstance.getWhereStatement();
        Test.stopTest();

        Assert.isTrue(String.isBlank(whereStatement), 'Expected the whereStatement to be blank');
    }

    @IsTest
    static void getWhereStatement_whereClausePopulated_returnWhereStatement() {
        String whereClause = 'Name != NULL';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withWhereClause(whereClause);
        String whereStatement = queryInstance.getWhereStatement();
        Test.stopTest();

        Assert.areEqual(
            ' WHERE ' + whereClause,
            whereStatement,
            'Expected the whereStatement to contain ' + whereClause
        );
    }

    @IsTest
    static void getOtherStatements_otherStatementsNull_returnBlank() {
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        String otherStatements = queryInstance.getOtherStatements();
        Test.stopTest();

        Assert.isTrue(String.isBlank(otherStatements), 'Expected the otherStatements to be blank');
    }

    @IsTest
    static void getOtherStatements_otherStatementsPopulated_returnOtherStatements() {
        String otherStatements = 'GROUP BY Name';
        AggregateQuery queryInstance = new AggregateQuery(Account.SObjectType);

        Test.startTest();
        queryInstance.withOtherStatements(otherStatements);
        String returnedOtherStatements = queryInstance.getOtherStatements();
        Test.stopTest();

        Assert.areEqual(
            ' ' + otherStatements,
            returnedOtherStatements,
            'Expected the otherStatements to be ' + otherStatements
        );
    }
}