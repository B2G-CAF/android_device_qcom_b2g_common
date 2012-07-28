MYLOC=$(dirname ${BASH_SOURCE[0]})
cp ${MYLOC}/xpcom.mk ${MYLOC}/clear_xpcom_vars.mk core/
git_add core/xpcom.mk core/clear_xpcom_vars.mk
