@{
    Severity = @('Error','Warning')
    ExcludeRules = @(
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSProvideCommentHelp',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingWriteHost',
        'PSAvoidUsingPlainTextForPassword'
    )
}