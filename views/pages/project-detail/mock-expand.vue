<template>
  <div class="em-mock-expand">
    <h2>Method</h2>
    <p>{{mock.method}}</p>
    <h2>URL</h2>
    <p>{{mock.url}}</p>
    <h2>{{$t('p.detail.expand.description')}}</h2>
    <p>{{mock.description}}</p>
    <Tabs value="request" v-if="mock.parameters || mock.response_model">
      <Tab-pane :label="$t('p.detail.expand.tab[0]')" name="request" v-if="mock.parameters">
        <Table :columns="columnsRequest" :data="request"></Table>
      </Tab-pane>
      <Tab-pane :label="$t('p.detail.expand.tab[1]')" name="response" v-if="mock.response_model">
        <Table :columns="columnsResponse" :data="response"></Table>
      </Tab-pane>
      <Tab-pane :label="$t('p.detail.expand.tab[2]')" name="tsmodal" v-if="mock.response_model">
        <Collapse>
          <Panel>
            request
            <div slot="content">
              <Button><Icon size="13" type="ios-copy-outline" /><span class="copy-btn" @click="copyCode($refs.typeReqRef.innerText)">复制代码</span></Button>
              <p ref="typeReqRef" v-for="r in request" v-html="r.tsType"></p>
            </div>
          </Panel>
          <Panel>
            response
            <div slot="content">
              <Button><Icon size="13" type="ios-copy-outline" /><span class="copy-btn" @click="copyCode($refs.typeResRef[0].innerText)">复制代码</span></Button>
              <div v-for="r in response">
                <p v-if="r.tsType" ref="typeResRef" v-html="r.tsType"></p>
              </div>
            </div>
          </Panel>
        </Collapse>
      </Tab-pane>
      <Tab-pane label="Service" name="class">
        <Collapse>
          <Panel>
            URL
            <div slot="content">
              <Button><Icon size="13" type="ios-copy-outline" /><span class="copy-btn" @click="copyCode($refs.urlRef.innerText)">复制代码</span></Button>
              <p ref="urlRef" v-html="url"></p>
            </div>
          </Panel>
          <Panel>
            Function
            <div slot="content">
              <Button><Icon size="13" type="ios-copy-outline" /><span class="copy-btn" @click="copyCode($refs.fcRef.innerText)">复制代码</span></Button>
              <p ref="fcRef" v-html="requestFc"></p>
            </div>
          </Panel>
        </Collapse>
      </Tab-pane>
    </Tabs>
  </div>
</template>

<script>
import {
  getJavaScriptEntities,
  getObjectiveCEntities
} from 'swagger-parser-mock/lib/entity'
import Clipboard from 'clipboard'
import jsBeautify from 'js-beautify/js/lib/beautify'
import DataTypeExpand from './data-type-expand'

export default {
  props: {
    mock: {}
  },
  data () {
    return {
      columnsRequest: [
        {
          type: 'expand',
          width: 50,
          render: (h, params) => h(DataTypeExpand, { props: { data: params.row.parameter } })
        },
        { title: this.$t('p.detail.expand.columnsRequest[0]'), key: 'name' },
        { title: this.$t('p.detail.expand.columnsRequest[1]'), key: 'description' },
        { title: this.$t('p.detail.expand.columnsRequest[2]'), key: 'paramType' },
        { title: this.$t('p.detail.expand.columnsRequest[3]'), key: 'dataType' }
      ],
      columnsResponse: [
        {
          type: 'expand',
          width: 50,
          render: (h, params) => h(DataTypeExpand, { props: { data: params.row.response } })
        },
        { title: this.$t('p.detail.expand.columnsResponse[0]'), key: 'code' },
        { title: this.$t('p.detail.expand.columnsResponse[1]'), key: 'message' }
      ]
    }
  },
  computed: {
    requestFc () {
      let str = `const function use${this.capitalizeFirstLetterOnly(this.mock.url)} () {<br />`
      if (this.mock.method === 'get') {
        str += ''
      } else {
        str += ''
      }
      return str
    },
    url () {
      return `const ${this.mock.url.replace(/\/{(.+?)}/g, '').split('/').at(-1).replace(/([A-Z])/g, '_$1').toUpperCase()} = "${this.mock.url.substring(this.mock.url.indexOf('/', 1) + 1)}"; // ${this.mock.description}`
    },
    tsResType () {
      return this.capitalizeFirstLetterOnly(this.mock.url.substring(this.mock.url.lastIndexOf('/') + 1)) + 'ResType'
    },
    request () {
      const parameters = this.mock.parameters ? JSON.parse(this.mock.parameters) : []
      return parameters.map(parameter => {
        return {
          name: parameter.name,
          description: parameter.description || this.$t('p.detail.expand.defaultDescription'),
          paramType: parameter.in,
          dataType: this.getParamDataType(parameter),
          parameter: parameter,
          tsType: this.compile(parameter.schema || parameter, {isNeedExport: true, typeName: this.capitalizeFirstLetterOnly(this.mock.url) + 'ReqType'})
        }
      })
    },
    response () {
      const responseModel = this.mock.response_model ? JSON.parse(this.mock.response_model) : {}
      return Object.keys(responseModel).map(code => {
        const response = responseModel[code]
        return {
          code: code,
          message: response.message || response.description || this.$t('p.detail.expand.defaultDescription'),
          response: response,
          tsType: code === '200' ? this.compile(response.schema || response, {isNeedExport: true, typeName: this.capitalizeFirstLetterOnly(this.mock.url) + 'ResType'}) : ''
        }
      })
    },
    entities () {
      const res = this.response.filter(o => {
        const code = o.code.toString()
        return code === '200' || code === 'default'
      })[0]
      const response = res ? res.response : {}

      return {
        js: getJavaScriptEntities(response).map(o => jsBeautify.js_beautify(o, { indent_size: 2 })),
        oc: getObjectiveCEntities(response)
      }
    }
  },
  methods: {
    getParamDataType (parameter) {
      const { type, schema } = parameter
      if (type) return type
      if (schema && schema.type) {
        return schema.type === 'array' ? schema.items.type : schema.type
      }
    },
    capitalizeFirstLetterOnly (url) {
      const str = url.replace(/\/{(.+?)}/g, '').split('/').at(-1)
      return str.charAt(0).toUpperCase() + str.slice(1)
    },
    copyCode (text) {
      const clipboard = new Clipboard('.copy-btn', {
        text: () => {
          return text
        }
      })
      clipboard.on('success', (e) => {
        e.clearSelection()
        clipboard.destroy()
        this.$Message.success('复制成功')
      })
    },
    getType (property, typeName) {
      if (property.type === 'string') {
        return property.enum ? property.enum.map(i => `"${i}"`).join(' | ') : 'string'
      } else if (property.type === 'integer') {
        return 'number'
      } else if (property.type === 'boolean') {
        return 'boolean'
      } else if (property.type === 'array') {
        return property.items.enum ? `${this.compile(property.items, {isNeedExport: false, typeName})}[]` : `${this.compile(property.items, {isNeedExport: false, typeName})}[]`
      } else if (property.type === 'object') {
        return this.compile(property, {isNeedExport: false, typeName})
      }
    },
    compile (schema, {isNeedExport = true, typeName = 'MyType'}) {
      let typeStr = ''
      if (schema.type === 'object') {
        typeStr += isNeedExport ? `export interface ${typeName} {<br />` : '{<br />'
        for (const prop in schema.properties) {
          typeStr += `&nbsp;${prop}${schema.required && !schema.required.includes(prop) ? '?' : ''}: ${this.getType(schema.properties[prop], typeName)};<br />`
        }
        typeStr += '}'
      } else {
        typeStr = (isNeedExport ? `export type ${typeName} = ` : '') + this.getType(schema, typeName)
      }
      return typeStr
    }
  }
}
</script>
