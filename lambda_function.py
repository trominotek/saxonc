import saxoncpe
import json
import tempfile
import traceback

def lambda_handler(event, context):
    try:
        with saxoncpe.PySaxonProcessor(license=True) as proc:
            xslt_proc = proc.new_xslt30_processor()

            # XML and XSLT as strings
            xml_input = "<root><message>Hello, Lambda!</message></root>"
            xslt_stylesheet = """
            <xsl:stylesheet version="3.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
              <xsl:output method="xml" indent="yes"/>
              <xsl:template match="/">
                <output>
                  <xsl:value-of select="/root/message"/>
                </output>
              </xsl:template>
            </xsl:stylesheet>
            """

            # Write both to temporary files
            with tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix=".xml") as xml_file, \
                 tempfile.NamedTemporaryFile(mode='w+', delete=False, suffix=".xsl") as xslt_file:

                xml_file.write(xml_input)
                xml_file.flush()

                xslt_file.write(xslt_stylesheet)
                xslt_file.flush()

                # Call transform
                result = xslt_proc.transform_to_string(
                    source_file=xml_file.name,
                    stylesheet_file=xslt_file.name
                )

            return {
                "statusCode": 200,
                "headers": {"Content-Type": "application/xml"},
                "body": result
            }

    except Exception as e:
        return {
            "statusCode": 500,
            "body": json.dumps({
                "error": str(e),
                "trace": traceback.format_exc()
            })
        }
