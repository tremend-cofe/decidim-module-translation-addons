/* eslint-disable no-invalid-this */
/* eslint no-unused-vars: 0 */
/* eslint id-length: ["error", { "exceptions": ["e"] }] */

function handleReportMissingTranslationCheck() {
    const suggestionTextElement = document.getElementById('translation-suggestion');
    suggestionTextElement.removeAttribute('required');
}

function handleReportWrongTranslationCheck() {
    const suggestionTextElement = document.getElementById('translation-suggestion');
    suggestionTextElement.setAttribute('required', '');
}

$('#missing').on('click', handleReportMissingTranslationCheck);
$('#wrong').on('click', handleReportWrongTranslationCheck);
