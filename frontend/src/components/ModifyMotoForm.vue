<template>
  <div id="wholePage">
    <b-navbar toggleable type="dark" variant="dark">
      <b-navbar-brand href="#">
        <img src="./Images/moovingLogoBlanco.png" alt= "Logo" style= "width:100px;">
      </b-navbar-brand>
    </b-navbar>
    <div class="jumbotron">
      <div class="container">
        <div class="row">
          <div class="col-sm-8 offset-sm-2">
            <div>
              <h2>Modify Motorbike Form</h2>
              <form @submit.prevent="handleSubmit">
                <div class="form-group">
                  <label for="licensePlate">License Plate</label>
                  <input type="text" v-model="moto.licensePlate" id="licensePlate" name="licensePlate" class="form-control" :class="{ 'is-invalid': submitted && ($v.moto.licensePlate.$error || error_matricula) }" />
                  <div v-if="submitted && ($v.moto.licensePlate.$error || error_matricula)" class="invalid-feedback">
                    <span v-if="!$v.moto.licensePlate.required">License Plate is required</span>
                    <span v-if="(!$v.moto.licensePlate.minLength) || (!$v.moto.licensePlate.maxLength)">License Plate must be exactly 8 characters</span>
                  </div>
                </div>
                <div v-if="error_matricula" style="margin-top: 20px;margin-bottom: 20px;">
                  <p style="color: red; font-size: 12px">Please check that the license plate is not equal to another motorbike's license plate</p>
                </div>
                <div class="form-group">
                  <label for="battery">Battery (km)</label>
                  <input type="text" v-model="moto.battery" id="battery" name="battery" class="form-control" :class="{ 'is-invalid': submitted && ($v.moto.battery.$error || error_battery_state) }" />
                  <div v-if="submitted && ($v.moto.battery.$error || error_battery_state)" class="invalid-feedback">
                    <span v-if="!$v.moto.battery.required">Battery is required </span>
                    <span v-if="(!$v.moto.battery.minValue) || (!$v.moto.battery.integer)">Battery must be a positive integer (included 0)</span>
                  </div>
                </div>
                <div v-if="error_battery_state" style="margin-top: 20px;margin-bottom: 20px;">
                  <p style="color: red; font-size: 12px">Please check that the state and the battery fields are consistent</p>
                </div>
                <div class="form-group">
                  <label for="state">State</label>
                  <select v-model="moto.state" id="state" name="state" class="form-control" :class="{ 'is-invalid': submitted && ($v.moto.state.$error || error_battery_state) }" >
                    <option disabled value="">Select State</option>
                    <option>AVAILABLE</option>
                    <option>REPAIRING</option>
                    <option>LOW BATTERY</option>
                    <option>UNREPAIRABLE</option>
                    <option>UNCHECKED</option>
                    <option>ACCIDENT</option>
                  </select>
                  <div v-if="submitted && ($v.moto.state.$error || error_battery_state)" class="invalid-feedback">
                    <span v-if="!$v.moto.state.required">State is required</span>
                  </div>
                </div>
                <div v-if="error_battery_state" style="margin-top: 20px;margin-bottom: 20px;">
                  <p style="color: red; font-size: 12px">Please check that the state and the battery fields are consistent</p>
                </div>
                <div class="form-group">
                  <button class="btn"
                          id="cancelButton"
                          type="button"
                          @click="cancel()"
                          style="margin-top: 20px;margin-left: 0px; margin-right: 9px; border-radius: 12px;
                      background-color: #ff6961;color: #ffffff; width: 140px;">
                    Cancel
                  </button>
                  <button class="btn btn-primary" id="saveButton" style="margin-top: 20px;margin-left: 9px; margin-right: 0px;border-radius: 12px; background-color: #343a40;color: #42b983; width: 140px">Save</button>
                </div>
              </form>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { required, minLength, maxLength, integer, minValue } from 'vuelidate/lib/validators'
import axios from 'axios'
export default {
  name: 'ModifyMotoForm',
  data () {
    return {
      email: '',
      id: 0,
      moto: {
        licensePlate: '',
        state: '',
        battery: null
      },
      submitted: false,
      error_matricula: false,
      error_battery_state: false
    }
  },
  validations: {
    moto: {
      licensePlate: { required, minLength: minLength(8), maxLength: maxLength(8) },
      state: { required },
      battery: { required, integer, minValue: minValue(0) }
    }
  },
  created () {
    this.email = this.$route.query.email
    this.id = this.$route.query.id
    this.getMotoInfo()
  },
  methods: {
    getMotoInfo () {
      const path = process.env.VUE_APP_CALL_PATH + '/mechanicMoto' + '/' + this.id
      console.log(process.env.VUE_APP_CALL_PATH + '/mechanicMoto' + '/' + this.id)
      axios.get(path)
        .then((res) => {
          this.moto.licensePlate = res.data.mechanic_moto.matricula
          if (res.data.mechanic_moto.state === 'LOW_BATTERY_FUEL') {
            this.moto.state = 'LOW BATTERY'
          } else {
            this.moto.state = res.data.mechanic_moto.state
          }
          this.moto.battery = parseInt(res.data.mechanic_moto.km_restantes)
        })
        .catch((error) => {
          console.error(error)
          alert('Error getting moto information')
        })
    },
    cancel () {
      this.$router.push({ path: '/mechanicMoto', query: { id: this.id, email: this.email } })
    },
    handleSubmit (e) {
      this.submitted = true
      // stop here if form is invalid
      this.$v.$touch()
      if (this.$v.$invalid) {
        return
      }

      const path = process.env.VUE_APP_CALL_PATH + '/moto' + '/' + this.id
      console.log(path)

      const parameters = {
        matricula: this.moto.licensePlate,
        // parse to floating number with precision 2
        km_restantes: parseFloat(this.moto.battery).toFixed(2),
        state: this.moto.state
      }
      if (parameters.state === 'LOW BATTERY') {
        parameters.state = 'LOW_BATTERY_FUEL'
      }
      axios.put(path, parameters)
        .then((res) => {
          // route to reloaded motorbike info page:
          this.$router.push({ path: '/mechanicMoto', query: { id: this.id, email: this.email } })
        })
        .catch((error) => {
          console.error(error)
          switch (error.response.status) {
            case 409:
              this.error_matricula = true
              this.error_battery_state = false
              // alert('Please check that the license plate is not equal to another motorbike\'s license plate')
              break
            case 400:
              this.error_matricula = false
              this.error_battery_state = true
              // alert('Please check that the state and the battery fields are consistent')
              break
            case 404:
              this.error_matricula = false
              this.error_battery_state = false
              alert(error)
              break
            default:
              this.error_matricula = false
              this.error_battery_state = false
              alert('Internal error')
              break
          }
        })
    }
  }
}
</script>

<style scoped>
#wholePage
{
  position:fixed;
  padding:0;
  margin:0;
  top:0;
  left:0;
  width: 100%;
  height: 100%;
  background-color: #e9ecef;
}
</style>
