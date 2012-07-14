MYLOC=$(dirname ${BASH_SOURCE[0]})
cp ${MYLOC}/xpidl.mk ${MYLOC}/create_install_rdf ${MYLOC}/create_chrome_manifest core/
git_add core/xpidl.mk core/create_install_rdf core/create_chrome_manifest
